import React from 'react'
import { subscriptions } from '../Data'

export default function Subscriptions({ add }){
  return (
    <div className="container">
      <h2>Subscriptions</h2>
      <div className="grid">
        {subscriptions.map(sub => (
          <div className="card" key={sub.id}>
            <h3>{sub.name}</h3>
            <p className="price">${sub.price.toFixed(2)}</p>
            <p>{sub.description}</p>
            <button className="btn" onClick={() => add({ id: sub.id, name: sub.name, price: sub.price, qty: 1, kind: 'subscription' })}>
              Add subscription
            </button>
          </div>
        ))}
      </div>
    </div>
  )
}
