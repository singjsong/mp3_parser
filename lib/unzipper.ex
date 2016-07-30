require IEx;

defmodule Unzipper do
  @folder '/Users/jhaber/Music'

  def start do
    :fs.start_link(:watcher, @folder)
    :fs.subscribe(:watcher)
    watch   
  end

  # handles only [created, modified, removed, renamed, undefined] (all the supported events of inotify-win)
  defp watch do
    receive do
      {_watcher_process, {:fs, :file_event}, {changed_file, type}} ->
        if to_string(changed_file) =~ ~R/\.(zip|rar|7z)$/i do
          results = :zip.unzip(changed_file, cwd: './tmp')
          mp3s = Path.wildcard("./tmp/*.mp3")

          # Load first mp3 to parse details
          binary = File.read!(List.first(mp3s))

          # ID3v2 parsing
          # First 23 bytes are irrelvant ID3v2 header stuff
          << _ :: binary-size(23),
            title :: binary-size(22), _ :: binary >> = binary
          IO.puts(title)
        else
          watch
        end

        watch
      end
  end
end
