
#ifndef _BLOCK_FIFO_H_
#define _BLOCK_FIFO_H_

#include <pthread.h>
#include "AVFRAMEINFO.h"

typedef pthread_mutex_t				av_mutex_t;
#define av_mutex_init(theMutex)		pthread_mutex_init(&theMutex, NULL)
#define av_mutex_lock(theMutex)		pthread_mutex_lock(&theMutex)
#define av_mutex_unlock(theMutex)	pthread_mutex_unlock(&theMutex)
#define av_mutex_destroy(theMutex)	

//#define IPC_FRAME_FLAG_IFRAME		0x01
//#define IPC_FRAME_FLAG_MD			0x02

//#define MAXALARMBYTES_toSERV		131072	//128*1024
//#define MAXBYTES_toSERV				262144	//256*1024
//
//#define MAXALARMBYTES_toCLIENT		131072	//128*1024
//#define MAXBYTES_toCLIENT			262144	//256*1024
//#define MAXBYTES_toCLIENT_DIV1024	256

enum E_FRM_STATE {	FRM_STAT_UNKNOWN=-1, FRM_STAT_COMPLETE, 
	FRM_STAT_INCOMPLETE, FRM_STAT_LOSED,
};

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

// 36bytes
typedef struct _ip_block
{
	struct _ip_block *p_next;
	
	FRAMEINFO_t	frmInfo;
	unsigned int	frameNo;
	char			frmState;	//E_FRM_STATE
	char			reserve1[3];
	
	unsigned int	buff_size;	//frame size
	char			*pBuffer;	//frame data
}ip_block_t;
	
	
//@desc: copy buf to b(block_t *), b be malloced first, cann't be NULL
//@para  0: fail
//		>0: success
int  ip_block_Alloc(ip_block_t *b, void *buf, unsigned int size);
void ip_block_Release(ip_block_t *p_block);


struct _ip_block_fifo
{
	av_mutex_t     lock;      // fifo data lock
	//pthread_cond_t wait;      //< Wait for data
	//pthread_cond_t wait_room; //< Wait for queue depth to shrink

	ip_block_t      *p_first;
	ip_block_t      **pp_last;

	unsigned int    i_depth;
	unsigned int    i_size;
};
typedef struct _ip_block_fifo	ip_block_fifo_t;

ip_block_fifo_t  *ip_block_FifoNew( void);
void          ip_block_FifoRelease(ip_block_fifo_t *p_fifo);
void          ip_block_FifoEmpty(ip_block_fifo_t *p_fifo);
unsigned int  ip_block_FifoPut(ip_block_fifo_t *p_fifo, ip_block_t *p_block);
ip_block_t    *ip_block_FifoGet( ip_block_fifo_t *p_fifo);
unsigned int  ip_block_FifoSize( const ip_block_fifo_t *p_fifo );
unsigned int  ip_block_FifoCount( const ip_block_fifo_t *p_fifo);

int			  ip_block_FifoExist(ip_block_fifo_t *p_fifo, unsigned long frmNo, unsigned long *pFrmNo);
//@return
//	>0  TRUE
//	<=0 FALSE
int			  ip_block_isIFrame(ip_block_t *b);
    int           ip_block_isFirstIFrame(ip_block_fifo_t *p_fifo);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif
