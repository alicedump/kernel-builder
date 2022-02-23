#! /bin/bash
KernelBranch="violet-slmk"

IncludeFiles "${MainPath}/device/merlin-r-oss.sh"
CustomUploader="Y"
IncludeFiles "${MainPath}/misc/kernel.sh" "https://${GIT_SECRET}@github.com/${GIT_USERNAME}/android_kernel_xiaomi_mt6768"
FolderUp="shared-file"
TypeBuildTag="[Stable][FullLTO]"

CloneKernel "--depth=1"
CloneAliceFiveTeenClang
OptimizaForPerf
CompileClangKernelLLVM && CleanOut