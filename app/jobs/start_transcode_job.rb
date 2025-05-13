# frozen_string_literal: true

class StartTranscodeJob < TranscodingJob
  def perform(movie)
    production_only do
      job_config = build_job_config(movie)
      job = transcoder_client.create_job parent: "projects/#{project_id}/locations/#{location}", job: job_config

      MonitorAndFinalizeTranscodeJob.set(wait: POLLING_INTERVAL).perform_later(movie, job.name)
    end
  end

  private

  def build_job_config(movie)
    {
      input_uri: input_uri(movie),
      output_uri: output_uri(movie),
      config: {
        elementary_streams:,
        mux_streams:
      }
    }
  end

  def input_uri(movie)
    "gs://#{bucket_name}/#{movie.movie_data.key}"
  end

  def output_uri(movie)
    "gs://#{bucket_name}/#{movie.id}/"
  end

  def elementary_streams
    [
      {
        key: 'video-stream',
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
        key: 'audio-stream',
        audio_stream: {
          codec: 'aac',
          bitrate_bps: 128_000
        }
      }
    ]
  end

  def mux_streams
    [
      {
        key: 'muxed-stream',
        container: 'mp4',
        elementary_streams: %w[video-stream audio-stream]
      }
    ]
  end
end
