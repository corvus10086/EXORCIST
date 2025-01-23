A custom Linux kernel is required before compilation.  
This custom kernel adds a hook to the pick_next_task function.  

The hook style is as follows   
void (*pebs_handler)(void) = NULL;  
EXPORT_SYMBOL(pebs_handler);  
if(pebs_handler!=NULL){  
		pebs_handler();  
}  

#How to Compile?
make  