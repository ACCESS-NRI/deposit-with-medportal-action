require "faraday"
require "securerandom"

#paper_path = ENV["PAPER_PATH"].to_s

# journal_data = {
#   doi_prefix: "10.21105",
#   url: "https://medportal-dev-6a745f452687.herokuapp.com/",
#   name: "ACCESS-NRI MedPortal",
#   alias: "medportal",
#   launch_date: "2023-08-14",
#   papers_repository: "ACCESS-NRI/med-recipes",
#   reviews_repository: "ACCESS-NRI/med-reviews",
#   deposit_url: "https://medportal-dev-6a745f452687.herokuapp.com/papers/api_deposit",
#   retract_url: "https://medportal-dev-6a745f452687.herokuapp.com/papers/api_retract"
# }

# journal = Theoj::Journal.new(journal_data)

# issue = Theoj::ReviewIssue.new(journal.data[:reviews_repository], issue_id)
# issue.paper = Theoj::Paper.new("", "", paper_path) unless paper_path.empty?

# submission = Theoj::Submission.new(journal, issue, issue.paper)

# deposit_call = submission.deposit!(journal_secret)

# if deposit_call.status.between?(200, 299)
#   system("echo 'Journal responded. Deposit looks good'")
#   system("echo 'paper_doi=#{submission.paper_doi}' >> $GITHUB_OUTPUT")
# else
#   system("echo 'CUSTOM_ERROR=Could not deposit with Open Journals.' >> $GITHUB_ENV")
#   raise "!! ERROR: Something went wrong with this deposit when calling #{journal.data[:deposit_url]}"
# end

issue_id = ENV["ISSUE_ID"]
journal_secret = ENV['JOURNAL_SECRET']
deposit_url = "https://medportal-dev-6a745f452687.herokuapp.com/papers/api_deposit"
doi = "10.21105/medportal.#{issue_id}"
title = SecureRandom.hex

def metadata_payload(title, issue_id, doi)
  {
    paper: {
      title: title,
      tags: ["Tag1", "Tag2"],
      languages: [],
      authors: [{"given_name"=>"Max",
                "middle_name"=>nil,
                "last_name"=>"Proft",
                "orcid"=>"0009-0003-1611-9516",
                "affiliation"=>
                 "Lyman Spitzer, Jr. Fellow, Princeton University, USA, Institution Name, Country"},
               {"given_name"=>"Author",
                "middle_name"=>"Without",
                "last_name"=>"Orcid",
                "orcid"=>nil,
                "affiliation"=>"Institution Name, Country"},
               {"given_name"=>"Author",
                "middle_name"=>"With no",
                "last_name"=>"Affiliation",
                "orcid"=>nil,
                "affiliation"=>"Independent Researcher, Country"}],
      doi: doi,
      archive_doi: doi,
      repository_address: 'https://github.com/max-anu/example-medportal1',
      editor: "@max-anu",
      reviewers: ["@max-anu",],
      volume: 1,
      issue: issue_id,
      year: 2023,
      page: issue_id,
    }
  }.to_json
end

def deposit_payload(title, issue_id, doi)
  {
    id: issue_id,
    metadata: Base64.encode64(metadata_payload(title, issue_id, doi)),
    doi: doi,
    archive_doi: doi,
    citation_string: "Proft et al., (2023). Gala: A Python package for galactic dynamics. ACCESS-NRI MedPortal, 1(1), 73, https://doi.org/10.21105/medportal.00073",
    title: title,
  }
end

def deposit!(secret, deposit_url, title, issue_id, doi)
  parameters = deposit_payload(title, issue_id, doi).merge(secret: secret)
  Faraday.post(deposit_url, parameters.to_json, {"Content-Type" => "application/json"})
end

deposit_call = deposit!(journal_secret, deposit_url, title, issue_id, doi)

if deposit_call.status.between?(200, 299)
  system("echo 'Journal responded. Deposit looks good'")
  system("echo 'paper_doi=#{doi}' >> $GITHUB_OUTPUT")
else
  system("echo 'CUSTOM_ERROR=Could not deposit with Open Journals.' >> $GITHUB_ENV")
  raise "!! ERROR: Something went wrong with this deposit when calling #{deposit_url}"
end
