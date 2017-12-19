
Pod::Spec.new do |s|

  s.name         = "SGDownload"
  s.version      = "0.0.3"

  s.summary      = "An iOS big file download tool"
  s.description    = "SGDownload is used to download Through which you can download it for big files At the same time support offline breakpoint downloading."


  s.homepage     = "https://github.com/install-b/OfflineBreakpointDownload"

  s.license      = "MIT"
  s.author             = { "ShangenZhang" => "gkzhangshangen@163.com" }
  s.platform     = :ios, "8.0"


  s.source       = { :git => "https://github.com/install-b/OfflineBreakpointDownload.git", :tag => s.version }



  s.source_files  = "SGDwonload/*.{h,m}"
  s.public_header_files = "SGDwonload/SGCacheManager.h", "SGDwonload/SGDownloadManager.h"


  s.framework  = "UIKit"

  s.requires_arc = true

end
