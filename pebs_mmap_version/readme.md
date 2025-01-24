## Here is the kernel module part of EXORCIST
# A custom Linux kernel
A custom Linux kernel is required before compilation.  
This custom kernel adds a hook to the pick_next_task function.  

The hook style is as follows 
```bash  
void (*pebs_handler)(void) = NULL;  
EXPORT_SYMBOL(pebs_handler);  
if(pebs_handler!=NULL){  
		pebs_handler();  
}  
```
After booting with the customized kernel, compilation can be performed.
# How to Compile?
```bash
make  
```
# How to use?
```bash
sudo insmod pebs.ko
```