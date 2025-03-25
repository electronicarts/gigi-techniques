This utility can turn an image into a marginal inverse CDF to let you do importance sampling on the image.

One common use for this is when sampling an HDR skybox in a scene, and wanting to use importance sampling.

===== Making Marginal ICDF =====

Step 1 is to set the imported resource "Input" to your texture, and set the "Source is sRGB" setting and texture format appropriately.

If you have a color image, you also need to modify the "InputDotProduct" variable to control how you convert your source image into greyscale. The default just uses the red channel.

A conversion from RGB to luminance is to set these values to: 0.299, 0.587, 0.114, 0.0

Step 2 is to click "Create" to create the marginal ICDF. It will be the output to the "CombineCDFs," which you can save to disk.

This image is the same size as the input, with an extra row of pixels at the top.

If you want a marginal ICDF that is a different size than your texture, for best results, you should make a copy of the source texture and resize it in another program such as Gimp, and use that in this utility.

Step 3 is to view the results in the output of the "Make_Comparison" pass.

This shows the original texture on the left, a reconstructed texture in the middle that used white noise samples to sample the marginal ICDF, and the error between the two on the right.

You can toggle absolute vs. relative error and color map vs. raw differences in the variables tab.

===== Sampling Marginal ICDF =====

The "PointSample" pass has code you can look at for how to sample the marginal ICDF.  The SampleICDF() function in PaintSample.hlsl can be copy/pasted and used where you want to sample it.

You need two random numbers to sample the ICDF.

More formally, you need a uniform point in a square [0,1]^2. You can use uniform white noise, or more exotic things such as Halton, Sobol, or the R2 sequence (https://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/).

The first random number is used to find the x value of your sampling location.  This is done by doing a binary search on row 0 of the ICDF image to find the first location not less than the value. The "PointSample" pass shows how to do a branchless binary search that is shader friendly.

After you have the x value of the sampling location, that determines which y axis row of pixels should be binary searched to give the y value of the sampling location.

At this point, you have the sampling location, in integer pixel coordinates, of the ICDF.

To convert to UV coordinates, you can cast to float, add 0.5 and divide by the size of the source image you gave to the utility.  You will then have a vec 2 value in [0,1]^2 which importance samples the input image.
 
