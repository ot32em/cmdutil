# utilities definitions
class util {
#    [TimeSpan]static duration([String]$filepath) {
#		#echo "filepath: $filepath"
#        $durationStr = $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $filepath)
#		Write-Output "durationStr: $durationStr"
#		$durationStr = $durationStr[0..($durationStr.count -4)]
#		return [TimeSpan]::Parse($durationStr)        
#    }
#	[Bool]static matchDuration([TimeSpan]$duration1, [TimeSpan]$duration2, [Int]$tolerance) {
#		$diff = $duration1 - $duration2
#		return [Math]::Abs($diff.TotalMilliseconds) -gt $tolerance
#	}
	static cleanFiles($filesToClean) {
		foreach($fileToClean in $filesToClean) { rm $fileToClean }
	}
}

# begin: parameters check
# parameters: at least 3 parameters for 1 output and 2+ input.
if($args.count -lt 3) {
	echo "Error: Invalid argument. concat_video.ps1 OUTPUT_FILENAME INPUT_FILENAME_1 INPUT_FILENAME_2 [INPUT_FILENAME_3 [...]]"
	exit
}

# parameter: output filename
$output = $args[0]
if(!$output) {
	echo "Error: Invalid argument. concat_video.ps1 OUTPUT_FILENAME INPUT_FILENAME_1 INPUT_FILENAME_2 [INPUT_FILENAME_3 [...]]"
	exit
}
if(!($output -like "*.mp4")) {
	echo "Error: Invalid argument. OUTPUT_FILENAME `"$output`" should be like `"*.mp4`""
	exit
}

# parameters: input filenames
$inputs =$args[1..($args.count-1)]
for( $i = 0; $i -lt $inputs.count; $i++) {
	$input = $inputs[$i]
	if(!($input -like "*.mp4")) {
		echo "Error: Invalid argument. INPUT_FILENAME_$($i+1) `"$input`" should be like `"*.mp4`""
		exit
	}
	if(!(Test-Path -PathType Leaf $input)) {
		echo "Error: Invalid argument. INPUT_FILENAME_$($i+1) `"$input`" does not exist"
		exit
	}
}
# done: parameters check


$intermediates = @("") * $inputs.count
#[Double]$inputTotalDuration = 0.0
$filesToClean = @("") * 0

for( $i = 0; $i -lt $inputs.count; $i++) {
	# begin: INPUT.mp4 -> INTERMEDIATE.ts
	$input = $inputs[$i]
	$intermediate = "_$((Get-Item $inputs[$i]).basename).ts"	
	$intermediates[$i] = $intermediate	
	
	ffmpeg -hide_banner -v error -i $input -c copy -bsf:v h264_mp4toannexb -f mpegts $intermediate	
	if (!$?) {
		echo "Error: ffmpeg command error. Failed to generate intermediate file for `"$input`""
		[util]::cleanFiles($filesToClean)
		exit
	}	
	#$inputDuration = [util]::duration($input)	
	#$intermidiateDuration = [util]::duration($intermediate)
	#if ([util]::matchDuration($inputDuration,$intermidiateDuration, 1)) { # diff need less than 1 second
	#	echo "Error: intermediate file result error. Generated intermediate file duration mismatched. input: $inputDuration intermediate: $intermidiateDuration"
	#	[util]::cleanFiles($filesToClean)
	#	exit
	#}
	
	# done: INPUT.mp4 -> INTERMEDIATE.ts
	$inputTotalDuration = $inputTotalDuration + $inputDuration
	$filesToClean += $intermediate
}

# begin: INTERMEDIATE_1.ts + INTERMEDIATE_2.ts + ... = OUTPUT.mp4
$intermediates_list = $intermediates -join "|"
ffmpeg -hide_banner -v error -f mpegts -i "concat:$intermediates_list" -c copy -bsf:a aac_adtstoasc $output
if (!$?) {
	echo "Error: ffmpeg command error. Failed to concatenate to output file `"$($output_filename)`""
	[util]::cleanFiles($filesToClean)
	exit
}
#$outputDuration = [util]::duration($output)
#if( ![util]::matchDuration($inputDuration, $inputTotalDuration, 1 * $inputs.count)) { # diff need less than `1 second x input count`
#	echo "Error: Output result error. Generated output file duration mismatched. Accumerated input duration: $inputTotalDuration output duration: $outputDuration"
#	[util]::cleanFiles($filesToClean)
#	exit
#}
# done: INTERMEDIATE_1.ts + INTERMEDIATE_2.ts + ... -> OUTPUT.mp4

[util]::cleanFiles($filesToClean)
echo "Success: `"$output`" is created by concatenating $(($inputs | %{`"[$((Get-Item $_).Name)]`"}) -join `", `") with duration: "