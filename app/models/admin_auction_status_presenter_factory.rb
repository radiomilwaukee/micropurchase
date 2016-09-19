class AdminAuctionStatusPresenterFactory
  attr_reader :auction

  def initialize(auction:)
    @auction = auction
  end

  def create
    if auction.purchase_card == 'default'
      default_purchase_card_presenter
    else
      other_purchase_card_presenter
    end.new(auction: auction)
  end

  private

  def default_purchase_card_presenter
    if auction.c2_status == 'not_requested'
      C2StatusPresenter::NotRequested
    elsif auction.c2_status == 'sent'
      C2StatusPresenter::Sent
    elsif auction.c2_status == 'pending_approval'
      C2StatusPresenter::PendingApproval
    elsif future? && auction.published?
      AdminAuctionStatusPresenter::Future
    elsif future? && auction.unpublished?
      AdminAuctionStatusPresenter::ReadyToPublish
    elsif work_in_progress?
      AdminAuctionStatusPresenter::WorkInProgress
    elsif auction.c2_paid?
      C2StatusPresenter::C2Paid
    elsif auction.payment_confirmed?
      C2StatusPresenter::PaymentConfirmed
    elsif !auction.pending_delivery?
      Object.const_get("AdminAuctionStatusPresenter::#{status}")
    else # auction.approved? && auction.pending_delivery?
      C2StatusPresenter::Approved
    end
  end

  def other_purchase_card_presenter
    if future? && auction.published?
      AdminAuctionStatusPresenter::Future
    elsif future? && auction.unpublished?
      AdminAuctionStatusPresenter::ReadyToPublish
    elsif work_in_progress?
      AdminAuctionStatusPresenter::WorkInProgress
    else
      Object.const_get("AdminAuctionStatusPresenter::#{status}")
    end
  end

  def future?
    AuctionStatus.new(auction).future?
  end

  def work_in_progress?
    AuctionStatus.new(auction).work_in_progress?
  end

  def status
    auction.status.camelize
  end

  def c2_status
    auction.c2_status.camelize
  end
end
