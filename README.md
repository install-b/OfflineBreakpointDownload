# OfflineBreakpointDownload 
离线断点下载器，基于文件句柄与NSURLSession实现的多文件离线断点下载器，下载较大文件时如音频、视频可以实时将下载的数据写入磁盘避免手机内存飙升导致崩溃，同时通过他添加下载任务可以实时监听下载进度。

# how to import for your project

  1、直接集成 (directly integrating)
  
  下载zip包解压后， 直接将 “SGDwonload” 文件夹下所有文件拖到你的项目 (Download the zip package decompression, directly under the "SGDwonload" folder to drag all your files to your project)
  
  
  2、使用CocoaPods  (use CocoaPods)
  
 To integrate SGDwonload into your Xcode project using CocoaPods, specify it in your Podfile:

	source 'https://github.com/CocoaPods/Specs.git'
	platform :ios, '8.0'
	
	target 'TargetName' do
	pod 'SGDwonload', '~> 0.0.3'
	end
Then, run the following command:

	$ pod install


# how to use

#### 1、下载任务：

导入头文件(import head file) : SGDownloadManager.h
    
	  添加下载任务：
	  add download task：
	  
	  SGDownloadManager *manager = [SGDownloadManager shareManager];
     [manager downloadWithURL:url
    
                     progress:^(NSInteger completeSize, NSInteger expectSize) { //下载进度
            
                                NSLog(@"任务：%zd -- %.2f%%",index,100.0 * completeSize / expectSize);
            
                     }
                    complete:^(NSDictionary *respose, NSError *error) { // 下载完成回调
      
                        if(error) { // 失败回调
                            NSLog(@"任务：%zd 下载错误%@",index,error);
                            return ;
                 		}
                    
                      NSLog(@"任务：%zd 下载完成%@",index,respose);

        }];
        
        暂停任务：
        suspend task :
        
        [manager supendDownloadWithUrl:url.absoluteString]; // 暂停下载 (suspend task)
        
        取消所有下载：
        cancel add tasks :     
        [manager stopAllDownloads]; // 取消所有下载 (cancel add tasks)
        
  // 成功回调respose的数据示例：
    		
    任务：2 下载完成{
    // 保存文件的文件名
    fileName = "772ace4b7a404a3ce025d08f5e786ce2.mp4"; 
    
    // 保存文件的本地路径
    filePath = "/Users/xxx/Library/Developer/CoreSimulator/Devices/7DCECAF6-0038-430B-8103-F021EEF75428/data/Containers/Data/Application/CB2103AC-7894-418D-9AD6-2DF6636A1C4B/Library/Caches/downloads/772ace4b7a404a3ce025d08f5e786ce2.mp4";
   
    fileSize = 4149462; // 已下载文件大小
   
    fileUrl = "http://120.25.226.186:32812/resources/videos/minion_08.mp4"; // 下载任务目标网络url
   
    isFinished = 1; // 0代表未完成
   
    totalSize = 4149462; // 文件总大小
    
#### 2、本地磁盘查询内存清理(Query local disk  and memory cleaner)：

导入头文件(import head file) : SGCacheManager.h

a、查询本地信息(Query file information form local disk)：

	查询文件下载信息 返回结果参考 上述 “成功回调respose的数据示例”
	调用类方法
	[SGCacheManager queryFileInfoWithUrl:url.absoluteString]

b、清理内存 (clear Memory/disk):

		/**  删除某个文件 */
		+ (BOOL)deleteFileWithUrl:(NSString *)url;

		/**  清理所有下载文件及下载信息 */
		+ (BOOL)clearDisks;
		
		/**  取消所有当前下载的文件 清理内存缓存的数据 */
		+ (BOOL)clearMemory;
		
		/**  取消所有当前下载的文件 删除磁盘所有的下载 清理内存缓存的数据 */
		+ (BOOL)clearMemoryAndDisk;


# SOME TIPS

使用该工具可能会在Xcode 控制台输出这样的log：
				
		nw_socket_set_common_sockopts setsockopt SO_NOAPNFALLBK failed: [42] Protocol not available, dumping backtrace:
		 [x86_64] libnetcore-856.1.8
		 0   libsystem_network.dylib             0x000000010b23380e __nw_create_backtrace_string + 123
		 1   libnetwork.dylib                    0x000000010c032194 nw_socket_add_input_handler + 3002
		 2   libnetwork.dylib                    0x000000010c00fdb8 nw_endpoint_flow_attach_protocols + 3768
		 3   libnetwork.dylib                    0x000000010c00edd5 nw_endpoint_flow_setup_socket + 563
		 4   libnetwork.dylib                    0x000000010c00db34 -[NWConcrete_nw_endpoint_flow startWithHandler:] + 2612
		 5   libnetwork.dylib                    0x000000010c028d11 nw_endpoint_handler_path_change + 1261
		 6   libnetwork.dylib                    0x000000010c028740 nw_endpoint_handler_start + 570
		 7   libnetwork.dylib                    0x000000010c040003 nw_endpoint_resolver_start_next_child + 2240
		 8   libdispatch.dylib                   0x000000
		
		 8   libdispatch.dylib                   0x000000的
		 8   libdispatch.dylib                   0x000000
		 8   libdispatch.dylib                   0x000000
 
 解决方案：
 1. 到 Edit Scheme (快捷键 command + shift + <)
 
 2.选择 Arguments 选项
 
 3.选择 environment variables 添加变量 OS_ACTIVITY_MODE = disable

 

