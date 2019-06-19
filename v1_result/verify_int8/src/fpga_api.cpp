#include "fpga_api.h"
#include <cstring>

#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

#define DATA_SIZE SIZE*(SIZE+1)*sizeof(int) // fpga bram data size

#define min(x,y) (((x)<(y))?(x):(y))

FPGA::FPGA(off_t data_addr, off_t api_addr)
{
    fd_ = open("/dev/mem", O_RDWR);
    data_ = static_cast<int*>(mmap(NULL, DATA_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd_, data_addr));
    api_ = static_cast<unsigned int*>(mmap(NULL, sizeof(unsigned int), PROT_READ|PROT_WRITE, MAP_SHARED,fd_, api_addr));
}

FPGA::~FPGA()
{
    munmap(data_, DATA_SIZE );
    munmap(api_, sizeof(unsigned int));
    close(fd_);
}

int* FPGA::matrix(void)
{
	return data_ + SIZE;
}

int* FPGA::vector(void)
{
	return data_;
}

const int* __attribute__((optimize("O0"))) FPGA::run()
{
    *api_ = 0x5555;
    while(*api_ == 0x5555);

    return data_;    
}

void FPGA::largeMV(const int* large_mat, const int* input,
		int* output, int M, int N)
{
	for(int m = 0; m < N ; ++m)
	{
		output[m] = 0;
	}
	
	int* vec = this->vector();
	int* mat = this->matrix();
	
	for(int n = 0; n < N ; n += SIZE)
	{
		for(int m = 0; m < M ; m += SIZE)
		{			
			int n_remain = min(SIZE, N-n);
			int m_remain = min(SIZE, M-m);
			
			// initialize input vector		
			memcpy(vec, input + m,  sizeof(int)*m_remain);
			memset(vec + m_remain, 0, sizeof(int)*(SIZE - m_remain));			
			
			// initialize matrix
			for(int nn = 0; nn < n_remain; ++nn)
			{
				memcpy(mat + SIZE*nn, large_mat + m + M*(n+nn), sizeof(int)*m_remain);
				memset(mat + SIZE*nn + m_remain, 0, sizeof(int)*(SIZE - m_remain));
			}
			
			for(int nn = n_remain; nn < SIZE; ++nn)
			{
				memset(mat + SIZE*nn, 0, sizeof(int)*SIZE);
			}

			const int* rst = this->run();

			for(int nn = 0; nn < n_remain; ++nn)
			{
				output[n + nn] += rst[nn];
			}
		} 
	}
}
