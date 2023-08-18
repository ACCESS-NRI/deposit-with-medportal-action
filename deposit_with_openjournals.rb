require "theoj"

issue_id = ENV["ISSUE_ID"]
paper_path = ENV["PAPER_PATH"].to_s
journal_alias = ENV['JOURNAL_ALIAS']
journal_secret = ENV['JOURNAL_SECRET']

# I must override the journal otherwise it looks in the wrong repo for the issue.
# journal_alias = ENV["JOURNAL_ALIAS"]
# journal = Theoj::Journal.new(Theoj::JOURNALS_DATA[journal_alias.to_sym])

journal_data = {
  doi_prefix: "10.00000",
  url: "https://medportal-dev-6a745f452687.herokuapp.com/",
  name: "ACCESS-NRI MedPortal",
  alias: "medportal",
  launch_date: "2023-08-14",
  papers_repository: "ACCESS-NRI/med-recipes",
  reviews_repository: "ACCESS-NRI/med-reviews",
  deposit_url: "https://medportal-dev-6a745f452687.herokuapp.com/papers/api_deposit",
  retract_url: "https://medportal-dev-6a745f452687.herokuapp.com/papers/api_retract"
}

journal = Theoj::Journal.new(journal_data)

issue = Theoj::ReviewIssue.new(journal.data[:reviews_repository], issue_id)
issue.paper = Theoj::Paper.new("", "", paper_path) unless paper_path.empty?

submission = Theoj::Submission.new(journal, issue, issue.paper)

deposit_call = submission.deposit!(journal_secret)

if deposit_call.status.between?(200, 299)
  system("echo 'Journal responded. Deposit looks good'")
  system("echo 'paper_doi=#{submission.paper_doi}' >> $GITHUB_OUTPUT")
else
  system("echo 'CUSTOM_ERROR=Could not deposit with Open Journals.' >> $GITHUB_ENV")
  raise "!! ERROR: Something went wrong with this deposit when calling #{journal.data[:deposit_url]}"
end
