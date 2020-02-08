if ($args.Count -lt 1) {
	echo "Error: Need input filename without extension"
	exit
}
$target_filename = $args[0]
$input1_filename = "$($target_filename)-A.mp4"
$input2_filename = "$($target_filename)-B.mp4"
$input3_filename = "$($target_filename)-C.mp4"
$input4_filename = "$($target_filename)-D.mp4"
$inputCount = 2
$output_filename = "$($target_filename).mp4"
if (!(Test-Path $input1_filename -PathType Leaf)) {
	echo "Error: $($input1_filename) does not exist!"
	exit
}
if (!(Test-Path $input2_filename -PathType Leaf)) {
	echo "Error: $($input2_filename) does not exist!"
	exit
}
if (Test-Path $output_filename -PathType Leaf) {
	echo "Error: $($output_filename) should not exist, output cannot be written!"
	exit
}

if (Test-Path $input3_filename -PathType Leaf) {
	$inputCount = 3
}

if (Test-Path $input4_filename -PathType Leaf) {
	$inputCount = 4
}

echo "Concat $($input1_filename) and $($input2_filename) to $($output_filename)"

if ($inputCount -eq 2) {
	echo "input (0/2) ready, generating (1/2)"
	ffmpeg -i $input1_filename -c copy -bsf:v h264_mp4toannexb -f mpegts intA.ts	
	if (!$?) {
		echo "failed to generate intermediate file for $($input1_filename)"
		exit
	}
	echo "input (1/2) ready, generating (2/2)"
	ffmpeg -i $input2_filename -c copy -bsf:v h264_mp4toannexb -f mpegts intB.ts
	echo "run 2"
	if (!$?) {
		echo "failed to generate intermediate file for $($input2_filename)"
		del intA.ts
		exit
	}

	echo "input (2/2) ready, concating to output"
	ffmpeg -f mpegts -i "concat:intA.ts|intB.ts" -c copy -bsf:a aac_adtstoasc $output_filename
	
	if (!$?) {
		echo "failed to concate to output file $($output_filename)"
		del intA.ts
		del intB.ts
		exit
	}
	del intA.ts
	del intB.ts
	del $input1_filename
	del $input2_filename
	echo "output is concated as $($output_filename)"
}

# hardcode version for input count, refactoring to variable count in the future
if ($inputCount -eq 4) {
	echo "input (0/4) ready, generating (1/4)"
	ffmpeg -i $input1_filename -c copy -bsf:v h264_mp4toannexb -f mpegts intA.ts	
	if (!$?) {
		echo "failed to generate intermediate file for $($input1_filename)"
		exit
	}
	
	echo "input (1/4) ready, generating (2/4)"
	ffmpeg -i $input2_filename -c copy -bsf:v h264_mp4toannexb -f mpegts intB.ts
	echo "run 2"
	if (!$?) {
		echo "failed to generate intermediate file for $($input2_filename)"
		del intA.ts
		exit
	}
	
	
	echo "input (2/4) ready, generating (3/4)"
	ffmpeg -i $input3_filename -c copy -bsf:v h264_mp4toannexb -f mpegts intC.ts
	echo "run 2"
	if (!$?) {
		echo "failed to generate intermediate file for $($input3_filename)"
		del intA.ts
		del intB.ts
		exit
	}
	
	
	echo "input (3/4) ready, generating (4/4)"
	ffmpeg -i $input4_filename -c copy -bsf:v h264_mp4toannexb -f mpegts intD.ts
	echo "run 2"
	if (!$?) {
		echo "failed to generate intermediate file for $($input4_filename)"
		del intA.ts
		del intB.ts
		del intC.ts
		exit
	}

	echo "input (4/4) ready, concating to output"
	ffmpeg -f mpegts -i "concat:intA.ts|intB.ts|intC.ts|intD.ts" -c copy -bsf:a aac_adtstoasc $output_filename
	
	if (!$?) {
		echo "failed to concate to output file $($output_filename)"
		del intA.ts
		del intB.ts
		del intC.ts
		del intD.ts
		exit
	}
	del intA.ts
	del intB.ts
	del intC.ts
	del intD.ts
	del $input1_filename
	del $input2_filename
	del $input3_filename
	del $input4_filename
	echo "output is concated as $($output_filename)"
}