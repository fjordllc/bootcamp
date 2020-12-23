# gem install octokit
system("gem install specific_install")
system("gem specific_install https://github.com/octokit/octokit.rb.git 4-stable")

require "octokit"

client      = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])
deployments = client.deployments(ENV["REPO_NAME"], ref: ENV["BRANCH_NAME"], task: :deploy, environment: :review)

deployment = if deployments.size.positive?
               deployments.first
             else
               client.create_deployment(ENV["REPO_NAME"], ENV["BRANCH_NAME"],
                                        { task:              :deploy,
                                          environment:       :review,
                                          description:       "review_app-#{ENV["SHORT_SHA"]}",
                                          required_contexts: [] })
             end

client.create_deployment_status(deployment[:url],
                                :success,
                                target_url:      ENV["REVIEW_URL"],
                                environment_url: ENV["REVIEW_URL"],
                                description:     "review_app")
