clear
* data generating process
set obs 10000 /* world population of 10,000 */
set seed 1
gen age = rnormal(75.2, 10) /* population mean = 75.2 */

* create sampling distribution
local samplesize = 5
local x = 1
while `samplesize' < 1001 {
local ++x
local samplesize2 = `samplesize'
gen mean`samplesize2' = .
forvalues replicate = 1/1000 /* sample 1000 times */{
gsample `samplesize', gen(selection) wor /* sampling without replacement */
gsort -selection
* calculate sample mean
egen mean = mean(age) if selection == 1
replace mean`samplesize2' = mean[1] in 1/1
drop mean selection
}
local samplesize = 5*`x'
}

* twoway (function y= normalden(x,`r(mean)',`r(sd)'), color(red) range(`r(min)' `r(max)'))
twoway (function y= normalden(x, 75.18503, 4.473201), range(34.12632 115.4826) color(red) dropline(75)) 

sum age
local mean = `r(mean)'
sum mean5
local min = `r(min)'
local max = `r(max)'
local x = 0
forvalues size = 5(5)1000 {
local ++x
di `size'
sum mean`size'
ret list
graph twoway (hist mean`size', color(gs11) ylabel(0 0.5 1 1.5)) ///
(scatteri 0 `mean' 0.001 `mean' , c(l) m(i) color(blue)) /// 
(scatteri 0 `r(mean)' 0.001 `r(mean)' , c(l) m(i) color(red)) /// 
			 , legend(off) ///
ylabel(, angle(horizontal) nogrid) ///
ytitle("Density") ///
xtitle("Sample mean ({it:{&mu}{subscript:0}})") xlabel(65 70 75 80 85)       ///
title("Sampling distribution") ///
subtitle("(Sample size = `size', 1000 samples)")
cd "D:\Hoc tap\Stata\khoa-hoc\map\pic\distribution"
graph export graph`x'.png, as(png) width(3840) height(2160) replace
}

* Create the video with FFmpeg
cd "D:\Hoc tap\Stata\khoa-hoc\map\pic\distribution"
shell "C:\Program Files\FFmpeg\bin\ffmpeg.exe" -framerate 1/.1 -i graph%d.png -c:v libx264 -r 30 -pix_fmt yuv420p distribution4.mp4
winexec "C:\Program Files\FFmpeg\bin\ffmpeg.exe" -i graph%d.png -b:v 3000k distribution3.mpg
winexec "C:\Program Files\FFmpeg\bin\ffmpeg.exe" -i graph%d.png -b:v 10000k distribution3.mpg


global inputFile "D:\Hoc tap\Stata\khoa-hoc\map\pic\distribution\distribution.mp4"
global outputFile "D:\Hoc tap\Stata\khoa-hoc\map\pic\distribution"
global butterflowLocation "C:\Program Files\butterflow"
! "$butterflowLocation\butterflow.exe" -r 25x -v --poly-s=0.01 --fast-pyr -o  ///
"$outputFile\smoothVideo_blend2.mp4" "$inputFile"

* Output: https://www.youtube.com/watch?v=A_KV6duuF6M
