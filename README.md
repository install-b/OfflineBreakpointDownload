# OfflineBreakpointDownload 
离线断点下载器，基于文件句柄与NSURLSession实现的多文件离线断点下载器，下载较大文件时如音频、视频可以实时将下载的数据写入磁盘避免手机内存飙升导致崩溃，同时通过他添加下载任务可以实时监听下载进度。

# how to import for your project

  1、直接集成 下载zip包解压后， 直接将 “SGDwonload” 文件夹下所有文件拖到你的项目
  
  2、使用CocoaPods
  
 To integrate SGDwonload into your Xcode project using CocoaPods, specify it in your Podfile:

	source 'https://github.com/CocoaPods/Specs.git'
	platform :ios, '8.0'
	
	target 'TargetName' do
	pod 'AFNetworking', '~> 3.0'
	end
Then, run the following command:

	$ pod install


# how to use

导入头文件 SGDownloadManager.h
    
	  添加下载任务：
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
        [manager supendDownloadWithUrl:url.absoluteString]; // 暂停下载
        
        取消所有下载：
        [manager stopAllDownloads]; // 取消所有下载
        
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

 

