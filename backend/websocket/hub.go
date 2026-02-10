package websocket

import (
	"log"
	"sync"
)

// Hub maintains the set of active clients and broadcasts messages to the clients
type Hub struct {
	// Registered clients mapped by user ID (multiple clients per user)
	clients map[uint]map[*Client]bool

	// Channel subscriptions: channelID -> set of userIDs
	subscriptions map[uint]map[uint]bool

	// Register requests from the clients
	register chan *Client

	// Unregister requests from clients
	unregister chan *Client

	// Subscribe to a channel
	subscribe chan *Subscription

	// Unsubscribe from a channel
	unsubscribe chan *Subscription

	// Broadcast messages to clients in a specific channel
	broadcast chan *BroadcastMessage

	mu sync.RWMutex
}

// BroadcastMessage represents a message to be broadcast to a channel
type BroadcastMessage struct {
	ChannelID uint
	Message   interface{}
}

// Subscription represents a channel subscription request
type Subscription struct {
	UserID    uint
	ChannelID uint
}

// NewHub creates a new Hub instance
func NewHub() *Hub {
	return &Hub{
		clients:       make(map[uint]map[*Client]bool),
		subscriptions: make(map[uint]map[uint]bool),
		register:      make(chan *Client),
		unregister:    make(chan *Client),
		subscribe:     make(chan *Subscription),
		unsubscribe:   make(chan *Subscription),
		broadcast:     make(chan *BroadcastMessage),
	}
}

// Run starts the hub's main loop
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			if h.clients[client.userID] == nil {
				h.clients[client.userID] = make(map[*Client]bool)
			}
			h.clients[client.userID][client] = true
			h.mu.Unlock()
			log.Printf("Client registered for user %d (total connections: %d)", client.userID, len(h.clients[client.userID]))

		case client := <-h.unregister:
			h.mu.Lock()
			if clientSet, ok := h.clients[client.userID]; ok {
				delete(clientSet, client)
				close(client.send)

				// If user has no more connections, remove from subscriptions
				if len(clientSet) == 0 {
					delete(h.clients, client.userID)
					// Remove user from all channel subscriptions
					for channelID, subscribers := range h.subscriptions {
						delete(subscribers, client.userID)
						if len(subscribers) == 0 {
							delete(h.subscriptions, channelID)
						}
					}
					log.Printf("Last client unregistered for user %d", client.userID)
				} else {
					log.Printf("Client unregistered for user %d (remaining connections: %d)", client.userID, len(clientSet))
				}
			}
			h.mu.Unlock()

		case sub := <-h.subscribe:
			h.mu.Lock()
			if h.subscriptions[sub.ChannelID] == nil {
				h.subscriptions[sub.ChannelID] = make(map[uint]bool)
			}
			h.subscriptions[sub.ChannelID][sub.UserID] = true
			h.mu.Unlock()
			log.Printf("User %d subscribed to channel %d", sub.UserID, sub.ChannelID)

		case sub := <-h.unsubscribe:
			h.mu.Lock()
			if subscribers, ok := h.subscriptions[sub.ChannelID]; ok {
				delete(subscribers, sub.UserID)
				if len(subscribers) == 0 {
					delete(h.subscriptions, sub.ChannelID)
				}
			}
			h.mu.Unlock()
			log.Printf("User %d unsubscribed from channel %d", sub.UserID, sub.ChannelID)

		case message := <-h.broadcast:
			h.mu.RLock()
			subscribers := h.subscriptions[message.ChannelID]
			h.mu.RUnlock()

			for userID := range subscribers {
				h.mu.RLock()
				clientSet, ok := h.clients[userID]
				h.mu.RUnlock()

				if ok {
					// Send to all clients for this user
					for client := range clientSet {
						select {
						case client.send <- message.Message:
						default:
							// Client's send channel is full, unregister it
							go func(c *Client) {
								h.unregister <- c
							}(client)
							log.Printf("Client send buffer full, disconnecting user %d", userID)
						}
					}
				}
			}
		}
	}
}

// BroadcastToChannel sends a message to all clients subscribed to a specific channel
func (h *Hub) BroadcastToChannel(channelID uint, message interface{}) {
	h.broadcast <- &BroadcastMessage{
		ChannelID: channelID,
		Message:   message,
	}
}

// Register registers a client with the hub
func (h *Hub) Register(client *Client) {
	h.register <- client
}

// Unregister removes a client from the hub
func (h *Hub) Unregister(client *Client) {
	h.unregister <- client
}

// SubscribeToChannel subscribes a user to a channel
func (h *Hub) SubscribeToChannel(userID uint, channelID uint) {
	h.subscribe <- &Subscription{
		UserID:    userID,
		ChannelID: channelID,
	}
}

// UnsubscribeFromChannel unsubscribes a user from a channel
func (h *Hub) UnsubscribeFromChannel(userID uint, channelID uint) {
	h.unsubscribe <- &Subscription{
		UserID:    userID,
		ChannelID: channelID,
	}
}
