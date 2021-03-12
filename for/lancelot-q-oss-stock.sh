#! /bin/bash
KernelBranch="eleven-upstream-mod"

IncludeFiles "${MainPath}/device/lancelot-q-oss.sh"
CustomUploader="Y"
IncludeFiles "${MainPath}/misc/kernel.sh" "https://${GIT_SECRET}@github.com/${GIT_USERNAME}/lancelot_kernels"
FolderUp="lancelot-stock"
doSFUp=$FolderUp
doOsdnUp=$FolderUp
TypeBuildTag="[STOCK]"

CloneKernel "--depth=1"
CloneCompiledGccEleven
CloneGugelClang
CompileClangKernel

# cleanup stuff after done
cd "${MainPath}"
rm -rf *