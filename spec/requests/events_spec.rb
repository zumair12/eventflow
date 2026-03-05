# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Events", type: :request do
  let(:venue)     { create(:venue, rows: 5, columns: 6) }
  let(:organizer) { create(:user, :organizer) }
  let(:attendee)  { create(:user, :attendee) }
  let(:admin)     { create(:user, :admin) }
  let!(:event)    { create(:event, :published, venue: venue, organizer: organizer, capacity: 20) }

  # ── Index ─────────────────────────────────────────────────────────────────
  describe "GET /events" do
    context "when not signed in" do
      it "allows access (public)" do
        get events_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "returns success" do
        get events_path
        expect(response).to have_http_status(:ok)
      end

      it "includes the event in the body" do
        get events_path
        expect(response.body).to include(event.title)
      end
    end

    context "with search filter" do
      before { sign_in attendee }

      it "filters events by title" do
        searchable_event = create(:event, :published, title: "Jazz Gala Night",
                                  venue: venue, organizer: organizer, capacity: 20)
        other_event      = create(:event, :published, title: "Rock Festival 2026",
                                  venue: venue, organizer: organizer, capacity: 20)
        get events_path, params: { q: "Jazz" }
        expect(response.body).to include("Jazz Gala Night")
        expect(response.body).not_to include("Rock Festival 2026")
      end
    end
  end

  # ── Calendar ──────────────────────────────────────────────────────────────
  describe "GET /events/calendar" do
    before { sign_in attendee }

    it "returns success" do
      get calendar_events_path
      expect(response).to have_http_status(:ok)
    end
  end

  # ── Show ──────────────────────────────────────────────────────────────────
  describe "GET /events/:id" do
    context "when not signed in" do
      it "allows access to published events" do
        get event_path(event)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in" do
      before { sign_in attendee }

      it "shows the event detail" do
        get event_path(event)
        expect(response.body).to include(event.title)
        expect(response.body).to include(event.venue.name)
      end
    end
  end

  # ── Create ────────────────────────────────────────────────────────────────
  describe "POST /events" do
    let(:valid_params) do
      {
        event: {
          title:       "New Test Event",
          description: "A brand new event",
          start_at:    5.days.from_now.iso8601,
          end_at:      5.days.from_now.change(hour: 22).iso8601,
          capacity:    10,
          price:       30.00,
          category:    "concert",
          venue_id:    venue.id
        }
      }
    end

    context "when signed in as organizer" do
      before { sign_in organizer }

      it "creates a new event and redirects" do
        expect {
          post events_path, params: valid_params
        }.to change(Event, :count).by(1)
        expect(response).to redirect_to(event_path(Event.last))
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "returns forbidden" do
        post events_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end
  end

  # ── Publish ───────────────────────────────────────────────────────────────
  describe "PATCH /events/:id/publish" do
    let!(:draft_event) { create(:event, :draft, venue: venue, organizer: organizer) }

    before { sign_in organizer }

    it "publishes the event" do
      patch publish_event_path(draft_event)
      expect(draft_event.reload.status).to eq("published")
    end
  end

  # ── Destroy ───────────────────────────────────────────────────────────────
  describe "DELETE /events/:id" do
    context "as admin" do
      let!(:evt_no_bookings) { create(:event, :published, venue: venue, organizer: organizer, capacity: 20) }

      before { sign_in admin }

      it "deletes the event" do
        expect {
          delete event_path(evt_no_bookings)
        }.to change(Event, :count).by(-1)
      end
    end
  end
end
