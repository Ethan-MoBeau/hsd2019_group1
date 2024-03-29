#include "fpga_api.h"
#include <cstring>
#define DATA_SIZE SIZE*(SIZE+1) // fpga bram data size

#define min(x,y) (((x)<(y))?(x):(y))

FPGA::FPGA(off_t data_addr, off_t api_addr)
{
    api_ = new unsigned int[SIZE];    // use api_ as tempolar output 
    data_ = new float[DATA_SIZE];	
}

FPGA::~FPGA()
{
    delete[] api_;
    delete[] data_;
}

float* FPGA::matrix(void)
{
	return data_ + SIZE;
}

float* FPGA::vector(void)
{
	return data_;
}

const float* FPGA::run()
{
    float* vec = this->vector();
    float* mat = this->matrix();
    float* out  = reinterpret_cast<float*>(api_);  

    for(int i = 0 ; i < SIZE; ++i)
    {
        out[i] = 0;

        for(int j = 0 ; j < SIZE; ++j)
           out[i] += vec[j] * mat[SIZE*i + j];
    }

	for(int i = 0 ; i < SIZE; ++i)
	{
		data_[i] = out[i];
	}

    return data_;    
}

void FPGA::largeMV(const float* large_mat, const float* input,
		float* output, int M, int N)
{
	for(int m = 0; m < N ; ++m)
	{
		output[m] = 0;
	}
	
	float* vec = this->vector();
    float* mat = this->matrix();
	
	for(int n = 0; n < N ; n += SIZE)
	{
		for(int m = 0; m < M ; m += SIZE)
		{			
			int n_remain = min(SIZE, N-n);
			int m_remain = min(SIZE, M-m);
			
			// initialize input vector		
			memcpy(vec, input + m,  sizeof(float)*m_remain);
			memset(vec + m_remain, 0, sizeof(float)*(SIZE - m_remain));			
			
			// initialize matrix
			for(int nn = 0; nn < n_remain; ++nn)
			{
				memcpy(mat + SIZE*nn, large_mat + m + M*(n+nn), sizeof(float)*m_remain);
				memset(mat + SIZE*nn + m_remain, 0, sizeof(float)*(SIZE - m_remain));
			}
			
			for(int nn = n_remain; nn < SIZE; ++nn)
			{
				memset(mat + SIZE*nn, 0, sizeof(float)*SIZE);
			}

			const float* rst = this->run();

			for(int nn = 0; nn < n_remain; ++nn)
			{
				output[n + nn] += rst[nn];
			}
		} 
	}
}
