# buildQt 从源代码自动构建Qt

## 说明
1. 本项目的主要目的是从源代码构建Qt的二进制版本(使用GithubActions自动构建)
2. 主要针对开源版本的Qt5版本
3. 主要构建`Windows版本`(使用`MinGW64`编译器)

## 版本
1. 无"RP"版本：从Qt完整源代码构建，构建绝大部分组件
2. 有"RP"版本：从Qt组件源代码构建，目前只构建qtbase、qttools、qttranslations、qtsvg共4个组件

## 目前已支持Qt5 完整版本
1. Qt5.15.17 MinGW810_32     (使用Qt官方默认编译器版本)
2. Qt5.15.17 MinGW810_64     (使用Qt官方默认编译器版本)
4. Qt5.15.17 MinGW810_64_RP  (使用Qt官方默认编译器版本)

## Qt5.15.17编译器
1. **mingw810_32**：[8.1.0-1-202411201005i686-8.1.0-gdb-11.2.0-release-posix-dwarf-rt_v6-rev0.7z](https://download.qt.io/online/qtsdkrepository/windows_x86/desktop/tools_mingw81/qt.tools.win32_mingw810/8.1.0-1-202411201005i686-8.1.0-gdb-11.2.0-release-posix-dwarf-rt_v6-rev0.7z) (Qt官方默认编译器版本)
2. **mingw810_64**：[8.1.0-1-202411201005x86_64-8.1.0-gdb-11.2.0-release-posix-seh-rt_v6-rev0.7z](https://download.qt.io/online/qtsdkrepository/windows_x86/desktop/tools_mingw81/qt.tools.win64_mingw810/8.1.0-1-202411201005x86_64-8.1.0-gdb-11.2.0-release-posix-seh-rt_v6-rev0.7z) (Qt官方默认编译器版本)
