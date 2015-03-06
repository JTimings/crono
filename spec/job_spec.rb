require "spec_helper"

class TestJob
  def perform;end
end

describe Crono::Job do
  let(:period) { Crono::Period.new(2.day) }
  let(:job) { Crono::Job.new(TestJob, period) } 

  it "should contain performer and period" do
    expect(job.performer).to be TestJob
    expect(job.period).to be period
  end

  describe "#perform" do
    it "should run performer in separate thread" do
      thread = job.perform.join
      expect(thread).to be_stop
    end
  end

  describe "#description" do
    it "should return job identificator" do
      expect(job.description).to be_eql("Perform TestJob every 2 days")
    end
  end

  describe "#save" do
    it "should save new job to DB" do
      expect(Crono::CronoJob.where(job_id: job.job_id)).to_not exist
      job.save
      expect(Crono::CronoJob.where(job_id: job.job_id)).to exist
    end

    it "should update saved job" do
      job.last_performed_at = Time.now
      job.save
      @crono_job = Crono::CronoJob.find_by(job_id: job.job_id)
      expect(@crono_job.last_performed_at).to be_eql(job.last_performed_at)
    end
  end
end