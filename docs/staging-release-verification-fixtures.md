# Staging release verification fixtures

Use the existing staging accounts from `db/fixtures/users.yml` with the repository fixture password `testtest`: `komagata` (admin), `mentormentaro` (mentor), `kimura` (learner), `advijirou` (adviser), and `kensyu` (trainee). Retired or inactive role examples include `kensyuowata` and `yameo`; their ability to sign in depends on the current application state.

## AI review support card

Open the product represented by `products.yml` label `product13` (`OS X Mountain Lionをクリーンインストールする`), then sign in as `mentormentaro` or `komagata`. The card should appear after the submission body. As `kimura` or `advijirou`, the card and its content should be absent. The `fictional_sample_for_product13` review is static display data, not an AI-generated review. Its `example.invalid` link is illustrative; this does not show that Docs, URLs, GitHub, or any other external source was fetched or included as model context.

## Other release PR smoke checks

Existing fixtures include `page1` and the published Docs pages in `pages.yml`, `question1` in `questions.yml`, `talk_komagata` in `talks.yml`, `bookmark29` for `product1` in `bookmarks.yml`, and checks such as `product2_check_komagata` in `checks.yml`. Use the relevant signed-in role to exercise the corresponding UI or API path from `config/routes/api.rb`; these are sample records, and their presence does not establish an external integration result. OAuth read/write tokens and the Anthropic API key must be configured through the staging environment for checks that call those services. They are not stored in these public fixtures.
