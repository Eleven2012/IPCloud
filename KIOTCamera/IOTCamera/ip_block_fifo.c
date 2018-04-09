#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ip_block_fifo.h"

// copy buf to b(block_t)
int ip_block_Alloc(ip_block_t *b, void *buf, unsigned int size)
{
	if(b == NULL) return 0; //return-----------------

	memset(b, 0, sizeof(ip_block_t));
//	b->p_next   = NULL;

	if(buf != NULL && size > 0){
		
        b->pBuffer = (char *)malloc(size);
		
        if (b->pBuffer==NULL)
            return 0; //return---
		else 
            memcpy(b->pBuffer, buf, size);
		
		b->buff_size = size;
	}

//	b->frameNo		=0;
//	b->frmState		=0;
//	b->onlineNum	=0;
//	memset(b->reserve1,0,sizeof(b->reserve1));
//	b->codec_id		=0;
//	b->flags		=0;
//	b->cam_index	=0;
//	b->timestamp	=0;
	
	return 1;	//return---------------------------
}

void ip_block_Release(ip_block_t *p_block)
{
	if(p_block!=NULL){
		if(p_block->pBuffer!=NULL){
			free(p_block->pBuffer);
			p_block->pBuffer=NULL;
			p_block->buff_size=0;			
		}
		p_block->p_next=NULL;
		free(p_block);
		p_block=NULL;		
	}
}


//==========================================================
//create and init a new fifo
ip_block_fifo_t *ip_block_FifoNew( void)
{
	ip_block_fifo_t *p_fifo = malloc( sizeof( ip_block_fifo_t));
	if( !p_fifo ) return NULL;

 	av_mutex_init( p_fifo->lock );
// 	vlc_cond_init( &p_fifo->wait );
// 	vlc_cond_init( &p_fifo->wait_room );
	p_fifo->p_first = NULL;
	p_fifo->pp_last = &p_fifo->p_first;
	p_fifo->i_depth = p_fifo->i_size = 0;
//	p_fifo->b_force_wake = false;

	return p_fifo;
}

//destroy a fifo and free all blocks in it.
void ip_block_FifoRelease(ip_block_fifo_t *p_fifo)
{
	if(p_fifo==NULL) return;

	ip_block_FifoEmpty( p_fifo );
// 	vlc_cond_destroy( &p_fifo->wait_room );
// 	vlc_cond_destroy( &p_fifo->wait );
 	av_mutex_destroy( p_fifo->lock );
	free( p_fifo );
	p_fifo=NULL;
}

//void block_FifoPace( block_fifo_t *fifo, size_t max_depth, size_t max_size);

//free all blocks in a fifo
void ip_block_FifoEmpty( ip_block_fifo_t *p_fifo)
{
	ip_block_t *block;
	if(p_fifo==NULL) return;

	av_mutex_lock(p_fifo->lock );
	block = p_fifo->p_first;
	if (block != NULL)
	{
		p_fifo->i_depth = p_fifo->i_size = 0;
		p_fifo->p_first = NULL;
		p_fifo->pp_last = &p_fifo->p_first;
	}
// 	vlc_cond_broadcast( &p_fifo->wait_room );
 	av_mutex_unlock(p_fifo->lock );

	while(block != NULL)
	{
		ip_block_t *buf;

		buf = block->p_next;
		ip_block_Release(block);
		block = buf;
	}
}

/**
* Immediately queue one block at the end of a FIFO.
* @param fifo queue
* @param block head of a block list to queue (may be NULL)
* @return total number of bytes appended to the queue
*/
unsigned int ip_block_FifoPut(ip_block_fifo_t *p_fifo, ip_block_t *p_block)
{
	unsigned int i_size = 0, i_depth = 0;
	ip_block_t *p_last;
	if(p_fifo==NULL || p_block == NULL) return 0;

	av_mutex_lock (p_fifo->lock);
    
	for(p_last = p_block; ; p_last = p_last->p_next)
	{
		i_size += p_last->buff_size;
		i_depth++;
        
		if(!p_last->p_next) break;
	}
    
	*p_fifo->pp_last = p_block;
	p_fifo->pp_last  = &p_last->p_next;
	p_fifo->i_depth  += i_depth;
	p_fifo->i_size   += i_size;

	// We queued at least one block: wake up one read-waiting thread 
    // vlc_cond_signal( &p_fifo->wait );
	av_mutex_unlock( p_fifo->lock );

	return i_size;
}

/**
* Dequeue the first block from the FIFO. If necessary, wait until there is
* one block in the queue. This function is (always) cancellation point.
*
* @return a valid block, or NULL if block_FifoWake() was called.
*/
ip_block_t *ip_block_FifoGet(ip_block_fifo_t *p_fifo)
{
	ip_block_t *b;
    
	if (p_fifo == NULL)
        return NULL;

 	av_mutex_lock( p_fifo->lock );
// 	mutex_cleanup_push( &p_fifo->lock );

	// Remember vlc_cond_wait() may cause spurious wakeups
	// (on both Win32 and POSIX)
//	while((p_fifo->p_first == NULL ) && !p_fifo->b_force_wake) vlc_cond_wait( &p_fifo->wait, &p_fifo->lock );

	b = p_fifo->p_first;

//	p_fifo->b_force_wake = false;
	if( b == NULL )
	{
		// Forced wakeup
		av_mutex_unlock( p_fifo->lock );
		return NULL;
	}

	p_fifo->p_first = b->p_next;
	p_fifo->i_depth--;
	p_fifo->i_size -= b->buff_size;

	if( p_fifo->p_first == NULL )
	{
		p_fifo->pp_last = &p_fifo->p_first;
	}

	// We don't know how many threads can queue new packets now.
// 	vlc_cond_broadcast( &p_fifo->wait_room );
 	av_mutex_unlock( p_fifo->lock );

	b->p_next = NULL;
	return b;
}

//FIXME: not thread-safe
unsigned int ip_block_FifoSize( const ip_block_fifo_t *p_fifo )
{
	if(p_fifo==NULL) return 0;
	else return p_fifo->i_size;
}

//FIXME: not thread-safe
unsigned int ip_block_FifoCount( const ip_block_fifo_t *p_fifo)
{
	if(p_fifo == NULL) return 0;
	else return p_fifo->i_depth;
}

int	ip_block_FifoExist(ip_block_fifo_t *p_fifo, unsigned long frmNo, unsigned long *pFrmNo)
{
	ip_block_t *block=NULL;
	if(p_fifo==NULL) return 0;

av_mutex_lock(p_fifo->lock);
	block = p_fifo->p_first;
	while(block != NULL)
	{
		if(block->frameNo==frmNo) return 1;
		block = block->p_next;
	}

	if(pFrmNo) (*pFrmNo)++;
av_mutex_unlock(p_fifo->lock);

	return 0;
}

int	ip_block_isIFrame(ip_block_t *b)
{
	if(b == NULL) return -1;
	else {
		int nRet=((int)b->frmInfo.flags & IPC_FRAME_FLAG_IFRAME);
		int r = (nRet==IPC_FRAME_FLAG_IFRAME) ? 1 : 0;
		return r;
	}
}

int ip_block_isFirstIFrame(ip_block_fifo_t *p_fifo)
{
    if (p_fifo == NULL)
        return -1;
    else
        return p_fifo->p_first == NULL ? -1 : ip_block_isIFrame(p_fifo->p_first);
}