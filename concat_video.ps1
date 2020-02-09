$output = $args[0]
class ff {
    [Double]static duration([String]$filepath) {
         return $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $filepath)
        
    }
	[Bool]static matchDuration([Double]$duration1, [Double]$duration2, [Int]$tolerance) {
		return [Math]::Abs($duration1 - $duration2) -gt $tolerance
	}
	static cleanFiles($filesToClean) {
		foreach($fileToClean in $filesToClean) { rm $fileToClean }
	}
}

#echo "Output Filename: $output"
if(!$output) {
	echo "Error: Argument missing: `"concat_video.ps1 INPUT_FILENAME1[ INPUT_FILENAME2[ ...] -output OUTPUT_FILENAME`""
	exit
}
if(!($output -like "*.mp4")) {
	echo "Error: Output filename `"$output`" need to be `"*.mp4`""
	exit
}
$inputs =$args[1..($args.count-1)]
for( $i = 0; $i -lt $inputs.count; $i++) {
	$input = $inputs[$i]
	if(!($input -like "*.mp4")) {
		echo "Error: INPUT FILENAME `"$input`" need to be `"*.mp4`""
		exit
	}
	if(!(Test-Path -PathType Leaf $input)) {
		echo "Error: INPUT FILENAME `"$input`" does not exist"
		exit
	}
}

# end of input parameters precondition check


$intermediates = @("") * $inputs.count
[Double]$inputTotalDuration = 0.0
$filesToClean = @("") * 0

for( $i = 0; $i -lt $inputs.count; $i++) {
	$input = $inputs[$i]
	$intermediate = "_$((Get-Item $inputs[$i]).basename).ts"	
	$intermediates[$i] = $intermediate
	
	#echo "Input $i Filename: $input"
	#echo "Intermediate $i Filename: $intermediate"
	
	ffmpeg -hide_banner -v error -i $input -c copy -bsf:v h264_mp4toannexb -f mpegts $intermediate
	
	if (!$?) {
		echo "Error: failed to generate intermediate file for $input1_filename"
		[ff]::cleanFiles($filesToClean)
		exit
	}
	[Double]$inputDuration = [ff]::duration($input)
	[Double]$intermidiateDuration = [ff]::duration($intermediate)
	#echo "input duration: $inputDuration"
	#echo "intermediate duration: $intermidiateDuration"
	if ([ff]::matchDuration($inputDuration,$intermidiateDuration, 1)) {
		echo "Error: Generated intermediate file duration mismatched. input: $inputDuration intermediate: $intermidiateDuration"
		[ff]::cleanFiles($filesToClean)
		exit
	}
	
	# done of input.mp4 -> input.ts
	$inputTotalDuration = $inputTotalDuration + $inputDuration
	$filesToClean += $intermediate
}

$intermediates_list = $intermediates -join "|"
ffmpeg -hide_banner -v error -f mpegts -i "concat:$intermediates_list" -c copy -bsf:a aac_adtstoasc $output


if (!$?) {
	echo "failed to concate to output file $($output_filename)"
	[ff]::cleanFiles($filesToClean)
	exit
}
$outputDuration = [ff]::duration($output)
if( ![ff]::matchDuration($inputDuration, $inputTotalDuration, 1 * $inputs.count)) {
	echo "Error: Generated output file duration mismatched. accumerated input duration: $inputDuration output duration: $outputDuration"
	[ff]::cleanFiles($filesToClean)
	exit
}

[ff]::cleanFiles($filesToClean)
#mkdir -force handled > $null
#if($?) {
	#foreach($input in $inputs) {
	#	mv $input handled/
	#}
#}
echo "$output is created by concating `"$($intermediates -join `"+`")`""