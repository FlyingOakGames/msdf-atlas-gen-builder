$zlibPath = Convert-Path -LiteralPath "./zlib"
$libpngPath = Convert-Path -LiteralPath "./libpng"
$freetypePath = Convert-Path -LiteralPath "./freetype"
$msdfPath = Convert-Path -LiteralPath "./msdf-atlas-gen"

$outputFolder = "./binaries"

Remove-Item $outputFolder -Recurse -ErrorAction SilentlyContinue
if (!(Test-Path -Path $outputFolder)) {New-Item $outputFolder -Type Directory >$null}

$buildFolder = "build"

$zlibBuild = "$zlibPath/$buildFolder"
$libpngBuild = "$libpngPath/$buildFolder"
$freetypeBuild = "$freetypePath/$buildFolder"
$msdfBuild = "$msdfPath/$buildFolder"

$zlibLib = "$zlibBuild/Release/zs.lib"
$libpngLib = "$libpngBuild/Release/libpng18_static.lib"
$freetypeLib = "$freetypeBuild/Release/freetype.lib"
$msdfLib = "$msdfBuild/Release/msdf-atlas-gen.lib"
			
Write-Host "Look for MSBuild with C++ support" -ForegroundColor DarkCyan

	Set-Alias vswhere -Value "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

	$msbuild = vswhere -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -find MSBuild\**\Bin\MSBuild.exe | select-object -first 1
	if (!(Test-Path -Path $msbuild))
	{
		Write-Host "`tNot installed. Build aborted." -ForegroundColor DarkRed
		Read-Host -Prompt "Press Enter to exit"
		Break
	}
	else
	{
		Write-Host "`tFound at: $msbuild"
		Set-Alias msbuild -Value "$msbuild"
	}

Write-Host "Generate zlib" -ForegroundColor DarkCyan

	Remove-Item $zlibBuild -Recurse -ErrorAction SilentlyContinue
	if (!(Test-Path -Path $zlibBuild)) {New-Item $zlibBuild -Type Directory >$null}

	cmake -S $zlibPath -B $zlibBuild -G "Visual Studio 17 2022" -A x64 -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreaded" >$null

	Write-Host "`tDone"

Write-Host "Build zlib" -ForegroundColor DarkCyan

	msbuild $zlibBuild/zlib.sln /t:zlibstatic /p:Configuration="Release" /p:Platform="x64" >$null

	Write-Host "`tDone"

Write-Host "Generate libpng" -ForegroundColor DarkCyan

	Remove-Item $libpngBuild -Recurse -ErrorAction SilentlyContinue
	if (!(Test-Path -Path $libpngBuild)) {New-Item $libpngBuild -Type Directory >$null}

	cmake -S $libpngPath -B $libpngBuild -G "Visual Studio 17 2022" -A x64 -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreaded" -DZLIB_LIBRARY="$zlibLib" -DZLIB_INCLUDE_DIR="$zlibPath" >$null

	Write-Host "`tDone"

Write-Host "Build libpng" -ForegroundColor DarkCyan

	msbuild $libpngBuild/libpng.sln /t:png_static /p:Configuration="Release" /p:Platform="x64" >$null
	
	Copy-Item -Path "$libpngPath/pnglibconf.h.prebuilt" -Destination "$libpngPath/pnglibconf.h"

	Write-Host "`tDone"

Write-Host "Generate freetype" -ForegroundColor DarkCyan

	Remove-Item $freetypeBuild -Recurse -ErrorAction SilentlyContinue
	if (!(Test-Path -Path $freetypeBuild)) {New-Item $freetypeBuild -Type Directory >$null}

	cmake -S $freetypePath -B $freetypeBuild -G "Visual Studio 17 2022" -A x64 -DBUILD_SHARED_LIBS=false -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreaded" -DZLIB_LIBRARY="$zlibLib" -DZLIB_INCLUDE_DIR="$zlibPath" -DPNG_LIBRARY="$libpngLib" -DPNG_PNG_INCLUDE_DIR="$libpngPath" >$null

	Write-Host "`tDone"

Write-Host "Build freetype" -ForegroundColor DarkCyan

	msbuild $freetypeBuild/freetype.sln /t:freetype /p:Configuration="Release" /p:Platform="x64" >$null

	Write-Host "`tDone"
	
Write-Host "Generate msdf-atlas-gen (standalone and static lib)" -ForegroundColor DarkCyan

	Remove-Item $msdfBuild -Recurse -ErrorAction SilentlyContinue
	if (!(Test-Path -Path $msdfBuild)) {New-Item $msdfBuild -Type Directory >$null}

	cmake -S $msdfPath -B $msdfBuild -G "Visual Studio 17 2022" -A x64 -DMSDF_ATLAS_USE_VCPKG=OFF -DMSDF_ATLAS_USE_SKIA=OFF -DFREETYPE_LIBRARY="$freetypeLib" -DFREETYPE_INCLUDE_DIRS="$freetypePath/include/freetype;$freetypePath/include" -DZLIB_LIBRARY="$zlibLib" -DZLIB_INCLUDE_DIR="$zlibPath" -DPNG_LIBRARY="$libpngLib" -DPNG_PNG_INCLUDE_DIR="$libpngPath" >$null

	Write-Host "`tDone"

Write-Host "Build msdf-atlas-gen (standalone and static lib)" -ForegroundColor DarkCyan

	msbuild $msdfBuild/msdf-atlas-gen.sln /t:msdf-atlas-gen /t:msdf-atlas-gen-standalone /p:Configuration="Release" /p:Platform="x64" >$null

	if (!(Test-Path -Path $outputFolder)) {New-Item $outputFolder -Type Directory >$null}
	Copy-Item -Path "$msdfBuild/bin/Release/msdf-atlas-gen.exe" -Destination "$outputFolder/msdf-atlas-gen.exe"
	Copy-Item -Path "$msdfBuild/Release/msdf-atlas-gen.lib" -Destination "$outputFolder/msdf-atlas-gen.lib"	
	
	Write-Host "`tDone"
	
Write-Host "Generate msdf-atlas-gen (dynamic lib)" -ForegroundColor DarkCyan

	Remove-Item $msdfBuild -Recurse -ErrorAction SilentlyContinue
	if (!(Test-Path -Path $msdfBuild)) {New-Item $msdfBuild -Type Directory >$null}

	cmake -S $msdfPath -B $msdfBuild -G "Visual Studio 17 2022" -A x64 -DBUILD_SHARED_LIBS=ON -DMSDF_ATLAS_USE_VCPKG=OFF -DMSDF_ATLAS_USE_SKIA=OFF -DFREETYPE_LIBRARY="$freetypeLib" -DFREETYPE_INCLUDE_DIRS="$freetypePath/include/freetype;$freetypePath/include" -DZLIB_LIBRARY="$zlibLib" -DZLIB_INCLUDE_DIR="$zlibPath" -DPNG_LIBRARY="$libpngLib" -DPNG_PNG_INCLUDE_DIR="$libpngPath" >$null

	Write-Host "`tDone"

Write-Host "Build msdf-atlas-gen (dynamic lib)" -ForegroundColor DarkCyan

	msbuild $msdfBuild/msdf-atlas-gen.sln /t:msdf-atlas-gen /p:Configuration="Release" /p:Platform="x64" >$null

	if (!(Test-Path -Path $outputFolder)) {New-Item $outputFolder -Type Directory >$null}
	Copy-Item -Path "$msdfBuild/Release/msdf-atlas-gen.dll" -Destination "$outputFolder/msdf-atlas-gen.dll"	
	
	Write-Host "`tDone"

Read-Host -Prompt "All done - Press Enter to exit"