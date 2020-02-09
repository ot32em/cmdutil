if ($args.Count -lt 3) {
	echo "Error: ./trim_video.ps1 FILENAME BEGIN_IN_HH:MM:SS END_IN_HH:MM:SS"
	exit
}
$input_filename = $args[0]
$output_filename = "$((Get-Item $input_filename).Basename)_trimmed$((Get-Item $input_filename).Extension)"

$begin_ts = $args[1]
$end_ts = $args[2]

if (!(Test-Path $input_filename -PathType Leaf)) {
	echo "Error: $($input_filename) does not exist!"
	exit
}
if (!($begin_ts -match '\d\d:\d\d:\d\d')) {
	echo "Error: begin '$begin_ts' should have format in `HH:MM:DD`!"
	exit
}
if (!($end_ts -match '\d\d:\d\d:\d\d')) {
	echo "Error: end '$end_ts' should have format in `HH:MM:DD`!"
	exit
}

ffmpeg -v error -ss $begin_ts -i $input_filename -to $end_ts -c copy $output_filename
