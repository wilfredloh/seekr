class JobsController < ApplicationController

    def home
      # for all jobs and messages under this user
      @jobs = Job.all.where(user_id: current_user)

      messages = Message.all.where(user_id: current_user)
      @messages = messages.reverse

      documents_user = Document.all.where(user_id: current_user)
      documents = []
      # p '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
      # p @documents
      # p '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
      documents_user.each do |doc|
        documents.push(doc.title)
      end
      @documents = ['-'] + documents
      # @resumes = resume_name #.sort_by{|doc| doc.resume}

      # for the 6 different statuses:
      # @created @applied @progress @result @offer @rejected
      @created = @jobs.length
      applied = @jobs.where(status:"Submitted")
      @applied = applied.length

      progress = 0
      count = 0
      @jobs.each do |job|
        if job.status.include?("1st") || job.status.include?("2nd")
          progress += 1
        end
        if job.created_at.to_date == Time.now.to_date
          count += 1
        end
      end
      @progress = progress
      @result = @jobs.where(status:"Awaiting Result").length
      @offer = @jobs.where(status:"Offer Received").length
      @rejected = @jobs.where(status:"Rejected").length

      # count number of jobs this user has created/applied today
      atoday = 0
      applied.each do |job|
        if job.created_at.to_date == Date.today
          atoday += 1
        end
      end
      @atoday = atoday
      @ctoday = count

      # getting all dates for deadlines/interviews of this user
      deadline = []
      interview = []
      @jobs.each do |job|
        if job.deadline.present?
          if job.deadline >= Date.today
            deadline.push(job)
          end
        end
        if job.interview.present?
          if job.interview >= Date.today
            interview.push(job)
          end
        end
      end
      @deadline = deadline.sort_by{|job| job.deadline}
      @interview = interview.sort_by{|job| job.interview}
    end





    def index

      documents_user = Document.all.where(user_id: current_user)
      documents = []
      # p '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
      # p @documents
      # p '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
      documents_user.each do |doc|
        documents.push(doc.title)
      end
      @documents = ['-'] + documents


      @jobs = Job.all.where(user_id: current_user)
      @sorted
      if params[:sortby] == "comp-asc"
        @sorted = @jobs.sort_by{|job| job.comp_name}
      elsif params[:sortby] == "comp-des"
        sorted = @jobs.sort_by{|job| job.comp_name}
        @sorted = sorted.reverse
      elsif params[:sortby] == "title-asc"
        @sorted = @jobs.sort_by{|job| job.title}
      elsif params[:sortby] == "title-des"
        sorted = @jobs.sort_by{|job| job.title}
        @sorted = sorted.reverse
      elsif params[:sortby] == "salary-asc"
        @sorted = @jobs.sort_by{|job| job.salary}
      elsif params[:sortby] == "salary-des"
        sorted = @jobs.sort_by{|job| job.salary}
        @sorted = sorted.reverse
      elsif params[:sortby] == "status-asc"
        @sorted = @jobs.sort_by{|job| job.stat_index}
      elsif params[:sortby] == "status-des"
        sorted = @jobs.sort_by{|job| job.stat_index}
        @sorted = sorted.reverse
      elsif params[:sortby] == "deadline-asc"
        no_date = []
        have_date = []
        @jobs.each do |job|
          if job.deadline == nil
            no_date.push(job)
          else
            have_date.push(job)
          end
        end
        sorted_date = have_date.sort_by{|job| job.deadline}
        @sorted = sorted_date + no_date
      elsif params[:sortby] == "deadline-des"
        no_date = []
        have_date = []
        @jobs.each do |job|
          if job.deadline == nil
            no_date.push(job)
          else
            have_date.push(job)
          end
        end
        sorted_date = have_date.sort_by{|job| job.deadline}
        reverse = sorted_date.reverse
        @sorted = reverse + no_date
      elsif params[:sortby] == "interview-asc"
        no_date = []
        have_date = []
        @jobs.each do |job|
          if job.interview == nil
            no_date.push(job)
          else
            have_date.push(job)
          end
        end
        sorted_date = have_date.sort_by{|job| job.interview}
        @sorted = sorted_date + no_date
      elsif params[:sortby] == "interview-des"
        no_date = []
        have_date = []
        @jobs.each do |job|
          if job.interview == nil
            no_date.push(job)
          else
            have_date.push(job)
          end
        end
        sorted_date = have_date.sort_by{|job| job.interview}
        reverse = sorted_date.reverse
        @sorted = reverse + no_date
      else
        @sorted = @jobs.sort_by{|job| job.status}
      end
    end


    def status

      documents_user = Document.all.where(user_id: current_user)
      documents = []
      # p '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
      # p @documents
      # p '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
      documents_user.each do |doc|
        documents.push(doc.title)
      end
      @documents = ['-'] + documents


      @jobs = Job.all.where(user_id: current_user)
      @job_started = @jobs.where(status: "Started").sort_by{|job| job.updated_at}
      @job_submitted = @jobs.where(status: "Submitted").sort_by{|job| job.updated_at}
      @job_interview = @jobs.where("status like ?", "%Interview%").sort_by{|job| job.interview}
      @job_awaiting = @jobs.where("status like ?", "%Awaiting%").sort_by{|job| job.updated_at}
      @job_offered = @jobs.where("status like ?", "%Offer%").sort_by{|job| job.updated_at}
      @job_rejected = @jobs.where(status: "Rejected").sort_by{|job| job.updated_at}
    end

    def show
      @job = Job.find(params[:id])
    end

    def create
      @job = Job.new(job_params)
      status = ['Started', 'Submitted', '1st Interview', '2nd Interview', 'Awaiting Results', 'Offer Received', 'Rejected']
      status.each_with_index do |stat, index|
        if @job.status == stat
          @job.stat_index = index+1
        end
      end

      @documents = Document.all.where(user_id: current_user)

      if params[:job][:doc] == '-'

      else
        new_doc = Document.find_by(:title => params[:job][:doc])
        @job.documents << new_doc
      end

      @job.user = current_user
      @job.save

      @message = Message.new(description:"Created:", job: @job, user: current_user)
      @message.save
      redirect_to root_path
    end

    def edit
      @job = Job.find(params[:id])
    end









    def update
      @job = Job.find(params[:id])
      status = ['Started', 'Submitted', '1st Interview', '2nd Interview', 'Awaiting Results', 'Offer Received', 'Rejected']
      status.each_with_index do |stat, index|
        if job_params[:status] == stat
          @job.stat_index = index+1
        end
      end

      @documents = Document.all.where(user_id: current_user)

      if @job.documents.length > 0
        if params[:job][:doc] == '-'
          old_doc = @job.documents[0]
          @job.documents.delete(old_doc)
        elsif params[:job][:doc] != @job.documents[0].title
          old_doc = @job.documents[0]
          @job.documents.delete(old_doc)
          new_doc = Document.find_by(:title => params[:job][:doc])
          @job.documents << new_doc
        end
      else
        if params[:job][:doc] == '-'

        else
          new_doc = Document.find_by(:title => params[:job][:doc])
          @job.documents << new_doc
        end
      end
      @job.update(job_params)

      @message = Message.new(description:"Updated:", job: @job, user: current_user)
      @message.save

      openFromURL = request.referrer

      if openFromURL.include?('status')
        redirect_to status_job_path
      elsif (URI(openFromURL).path  == "/jobs")
        redirect_to jobs_path
      else
        redirect_to root_path
      end
    end

    def destroy
      @job = Job.find(params[:id])
      @job.destroy

      openFromURL = request.referrer
      if openFromURL.include?('status')
          redirect_to status_job_path
        elsif (URI(openFromURL).path  == "/jobs")
          redirect_to jobs_path
        else
          redirect_to root_path
      end
    end

private

    def job_params
      params.require(:job).permit(:comp_name, :title, :location, :salary, :url, :deadline, :interview, :status, :ind, :notes, :document_ids => [])
    end

    def doc_params
      params.require(:document).permit(:title, :job_ids => [])
    end
end