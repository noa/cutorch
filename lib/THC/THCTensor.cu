#include "THCTensor.h"

cudaTextureObject_t THCudaTensor_getTextureObject(THCState *state, THCudaTensor *self)
{
  THAssert(THCudaTensor_checkGPU(state, 1, self));
  cudaTextureObject_t texObj;
  struct cudaResourceDesc resDesc;
  memset(&resDesc, 0, sizeof(resDesc));
  resDesc.resType = cudaResourceTypeLinear;
  resDesc.res.linear.devPtr = THCudaTensor_data(state, self);
  resDesc.res.linear.sizeInBytes = THCudaTensor_nElement(state, self) * 4;
  resDesc.res.linear.desc = cudaCreateChannelDesc(32, 0, 0, 0,
                                                  cudaChannelFormatKindFloat);
  struct cudaTextureDesc texDesc;
  memset(&texDesc, 0, sizeof(texDesc));
  cudaCreateTextureObject(&texObj, &resDesc, &texDesc, NULL);
  cudaError errcode = cudaGetLastError();
  if(errcode != cudaSuccess) {
    if (THCudaTensor_nElement(state, self) > 2>>27)
      THError("Failed to create texture object, "
              "nElement:%ld exceeds 27-bit addressing required for tex1Dfetch. Cuda Error: %s",
              THCudaTensor_nElement(state, self), cudaGetErrorString(errcode));
    else
      THError("Failed to create texture object: %s", cudaGetErrorString(errcode));
  }
  return texObj;
}

int THCudaTensor_getDevice(THCState* state, const THCudaTensor* self) {
  THCudaStorage *storage = THCudaTensor_storage(state, self);
  THAssert(storage != NULL);
  return THCudaStorage_getDevice(state, storage);
}

void THCudaTensor_setDevice(THCState* state, THCudaTensor* self, int device) {
  THCudaStorage *storage = THCudaTensor_storage(state, self);
  THAssert(storage != NULL);
  THCudaStorage_setDevice(state, storage, device);
}