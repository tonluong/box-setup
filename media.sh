yts() {
  if [ -z "$1" ]; then
    echo "Usage: yts <search terms>"
    echo "Example: yts bloomberg live"
    return 1
  fi
  
  # yt-dlp searches for the top 3 results and prints the ID and Title
  yt-dlp --print "%(id)s - %(title)s" "ytsearch3:$*"
}

yt() {
  local video_id
  local quality=""

  if [[ "$1" == "360" || "$1" == "720" || "$1" == "term" ]]; then
    quality="$1"
    shift
  fi

  # Check if standard input is NOT a terminal (meaning data is being piped in)
  if [ ! -t 0 ]; then
    # Read the first line from the pipe
    read -r line

    # Extract the video ID (grabs the first word before the space)
    video_id=$(echo "$line" | awk '{print $1}')

    # Silently consume the rest of the search results so yt-dlp
    # doesn't throw a "broken pipe" error when we stop reading
    cat > /dev/null
  else
    video_id="$1"
  fi

  if [ -z "$video_id" ]; then
    echo "Usage: yt [360|720|term] <video_id>"
    echo "       yts <search terms> | yt [360|720|term]"
    return 1
  fi

  if [[ "$quality" == "360" ]]; then
    echo "Playing 360p: $video_id"
    mpv --autofit-smaller=640x480 --ytdl-format="bestvideo[height=?360][fps<=?30][vcodec!=?vp9]+bestaudio/best" "ytdl://$video_id"
  elif [[ "$quality" == "720" ]]; then
    echo "Playing 720p: $video_id"
    mpv --autofit-smaller=640x480 --ytdl-format="bestvideo[height=?720][fps<=?30][vcodec!=?vp9]+bestaudio/best" "ytdl://$video_id"
  elif [[ "$quality" == "term" ]]; then
    echo "Terminal playback: $video_id"
    mpv --vo=tct "ytdl://$video_id"
  else
    echo "Playing: $video_id"
    mpv "ytdl://$video_id"
  fi
}

yta() {
  local video_id
  # Default chain: Try 91 first, fallback to 140 (standard m4a), 
  # then best isolated audio, then best combined stream.
  local format="91/140/bestaudio/best" 

  if [[ "$1" == "-q" || "$1" == "--quality" ]]; then
    if [[ "$2" == "high" ]]; then
      format="bestaudio/best"
    elif [[ "$2" == "low" ]]; then
      format="worstaudio/worst"
    else
      # If you pass a specific code, still give it a failsafe
      format="$2/bestaudio/best"
    fi
    shift 2 
  fi

  if [ ! -t 0 ]; then
    read -r line
    video_id=$(echo "$line" | awk '{print $1}')
    cat > /dev/null
  else
    video_id="$1"
  fi

  if [ -z "$video_id" ]; then
    echo "Usage: yta [-q <low|high|format_code>] <video_id>"
    echo "       yts <search terms> | yta [-q <low|high|format_code>]"
    return 1
  fi

  echo "Streaming audio for: $video_id (Format chain: $format)"
  
  # Added the script-opts flag to strictly force mpv to use yt-dlp, 
  # preventing it from accidentally falling back to old youtube-dl.
  mpv --no-config --no-video --script-opts=ytdl_hook-ytdl_path=yt-dlp --ytdl-format="$format" "ytdl://$video_id"
}

