class StartTranscodeJob < TranscodingJob
  def perform(movie)
    production_only do
      input_uri = "gs://#{bucket_name}/#{movie.movie_data.key}"
      output_uri = "gs://#{bucket_name}/#{movie.id}/"

      job_config = {
        input_uri: input_uri,
        output_uri: output_uri,
        config: {
          elementary_streams: [
            {
              key: "video-stream",
              video_stream: {
                h264: {
                  height_pixels: 1080,
                  width_pixels: 1920,
                  bitrate_bps: 12_000_000,
                  frame_rate: 120
                }
              }
            },
            {
              key: "audio-stream",
              audio_stream: {
                codec: "aac",
                bitrate_bps: 128_000
              }
            }
          ],
          mux_streams: [
            {
              key: "muxed-stream",
              container: "mp4",
              elementary_streams: ["video-stream", "audio-stream"]
            }
          ]
        }
      }

      job = transcoder_client.create_job parent: parent_path, job: job_config

      MonitorAndFinalizeTranscodeJob.set(wait: POLLING_INTERVAL).perform_later(movie, job.name)
    end
  end
end
