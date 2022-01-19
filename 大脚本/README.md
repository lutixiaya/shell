目前正在写一个大脚本，之所以称之为大，其实只是想写一个综合性的脚本。目前写的是第一版本（v1），主要是功能实现，里面还有许多优化的地方，希望一起学习探讨。

该脚本目前主要分为2个板块：**常见服务部署**和**系统资源查看**。

![image](https://user-images.githubusercontent.com/48750425/150093293-80a2f799-6508-4abd-a2e4-4b20091567c7.png)

### 常见服务部署：

其中常见服务部署中，包含**源码方式部署**和**yum方式部署**两种，部署前会检查网络是否通畅，网络正常则继续部署，否则返回错误提示。

![image](https://user-images.githubusercontent.com/48750425/150093426-5817f1fd-a63c-422e-8a9d-7ceb26e44056.png)

目前不管是源码还是yum，整合了nginx，MySQL，redis，其他的服务将在**v2**版本中更新！

![image](https://user-images.githubusercontent.com/48750425/150093444-91f088d4-a3a8-4cab-899d-13e95d1bf4a1.png)

在选择安装nginx时，如果系统已经安装了nginx的其他版本，会提示退出；否则可以根据需要安装指定版本：

![image](https://user-images.githubusercontent.com/48750425/150093470-a1e2850d-8b02-42fd-a328-c2330939a74f.png)

![image](https://user-images.githubusercontent.com/48750425/150093496-a66c8c7b-87ad-4ce9-97dc-be2c4c0145ca.png)

自动部署完成，给出安装结果：

![image](https://user-images.githubusercontent.com/48750425/150093567-98fb971a-2cc1-4465-ba70-cec7c540e8d9.png)

对于MySQL和redis服务，也是采用了同样的方式，**MySQL提供了主流的5.5、5.7、8.0版本**，**redis提供了4.0、5.0、6.2版本**：



### 系统资源查看

在系统资源菜单中，目前可以查看cpu，硬盘，内存信息。

![image](https://user-images.githubusercontent.com/48750425/150093566-5a54b509-c51b-42e2-8ed6-50ce02e38326.png)

CPU信息可以查看**型号**，**核心**和**负载**等信息：


硬盘可以查看**使用率**等信息：

![image](https://user-images.githubusercontent.com/48750425/150093610-cc342c68-5dda-4e69-9c63-0175e6100965.png)

后面将继续更新更多功能，优化细节，欢迎 **pr、issues**。

