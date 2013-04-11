require 'spec_helper'
 
 describe Request do

 	it "has a valid factory" do
 		FactoryGirl.create(:request).should be_valid
 	end

	it "is invalid without a bibid" do 
		FactoryGirl.build(:request, bibid: nil).should_not be_valid
	end

	context "Working with holdings data" do

		context "retrieving holdings data for its bib id" do

			it "returns nil if no bibid is passed in" do
				request = FactoryGirl.build(:request, bibid: nil)
				result = request.get_holdings
				result.should == nil
			end

			it "returns nil for an invalid bibid" do
				request = FactoryGirl.build(:request, bibid: 500000000)
				VCR.use_cassette 'holdings/invalid_bibid' do
					result = request.get_holdings
					result[request.bibid.to_s]['condensed_holdings_full'].should == []
				end
			end

			it "returns a condensed holdings record if type = 'retrieve'" do
				request = FactoryGirl.build(:request, bibid: 6665264)
				VCR.use_cassette 'holdings/condensed' do
					result = request.get_holdings 'retrieve' 
					result[request.bibid.to_s]['condensed_holdings_full'].should_not == []
				end
			end

			it "returns a condensed holdings record if no type is specified" do
				request = FactoryGirl.build(:request, bibid: 6665264)
				VCR.use_cassette 'holdings/condensed' do
					result = request.get_holdings
					result[request.bibid.to_s]['condensed_holdings_full'].empty?.should_not == true
				end
			end

			it "returns a verbose holdings record if type = 'retrieve_detail_raw" do
				request = FactoryGirl.build(:request, bibid: 6665264)
				VCR.use_cassette 'holdings/detail_raw' do
					result = request.get_holdings 'retrieve_detail_raw' 
					result[request.bibid.to_s]['records'].empty?.should_not == true
				end
			end

		end

		context "retrieving item types" do

			describe "get_item_type" do

				let(:request) { FactoryGirl.create(:request) }
				let(:day_loan_types) {
					[1, 5, 6, 7, 8, 10, 11, 13, 14, 15, 17, 18, 19, 20, 21, 23, 24, 25, 28, 33]
				}
				let(:minute_loan_types) {
					[12, 16, 22, 26, 27, 29, 30, 31, 32, 34, 35, 36, 37]
				}
				let(:nocirc_loan_types) { [9] }

				it "returns 'day' for a day-type loan" do
					day_loan_types.each do |t|
						request.loan_type(t).should == 'day'
					end
				end

				it "returns 'minute' for a minute-type loan" do
					minute_loan_types.each do |t|
						request.loan_type(t).should == 'minute'
					end
				end

				it "returns 'nocirc' for a non-circulating item" do
					nocirc_loan_types.each do |t|
						request.loan_type(t).should == 'nocirc'
					end
				end

				it "returns 'regular' for a regular loan" do
					(1..37).each do |t|
						unless day_loan_types.include? t or minute_loan_types.include? t or nocirc_loan_types.include? t
							request.loan_type(t).should == 'regular'
						end
					end
				end

				it "returns 'regular' if the loan type isn't recognized" do # is this really what we want?
					request.loan_type(-100).should == 'regular'
				end

			end

		end

	end

 end

