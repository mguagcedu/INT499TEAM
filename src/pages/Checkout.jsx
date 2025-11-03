import React, { useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'

function genOrderId(){
  const n = Math.random().toString(36).slice(2,8).toUpperCase()
  const t = Date.now().toString().slice(-4)
  return `EZ-${n}-${t}`
}

export default function Checkout({ items, total, clearCart }){
  const [form, setForm] = useState({ name:'', email:'', address:'', city:'', state:'', zip:'' })
  const [error, setError] = useState(null)
  const [placed, setPlaced] = useState(null)
  const nav = useNavigate()

  const valid = useMemo(()=>{
    const {name,email,address,city,state,zip} = form
    return name && /.+@.+\..+/.test(email) && address && city && state && /\d{5}/.test(zip)
  },[form])

  const onSubmit = (e) => {
    e.preventDefault()
    setError(null)
    if(!valid){ setError('Please complete all fields with valid information.'); return }
    if(items.length===0){ setError('Your cart is empty.'); return }
    const id = genOrderId()
    setPlaced(id)
    clearCart()
  }

  if(placed){
    return (
      <div className="container">
        <h2>Order confirmed</h2>
        <p className="price">Thanks for your purchase. Your order id is <span className="orderid">{placed}</span>.</p>
        <button className="btn" onClick={()=>nav('/')}>Back to Home</button>
      </div>
    )
  }

  return (
    <div className="container">
      <h2>Checkout</h2>
      <div className="grid" style={{gridTemplateColumns:'2fr 1fr'}}>
        <form className="form" onSubmit={onSubmit}>
          <div className="row">
            <input className="input" placeholder="Full name" value={form.name} onChange={e=>setForm({...form,name:e.target.value})} />
            <input className="input" placeholder="Email" value={form.email} onChange={e=>setForm({...form,email:e.target.value})} />
          </div>
          <input className="input" placeholder="Address" value={form.address} onChange={e=>setForm({...form,address:e.target.value})} />
          <div className="row">
            <input className="input" placeholder="City" value={form.city} onChange={e=>setForm({...form,city:e.target.value})} />
            <input className="input" placeholder="State" value={form.state} onChange={e=>setForm({...form,state:e.target.value})} />
          </div>
          <div className="row">
            <input className="input" placeholder="ZIP" value={form.zip} onChange={e=>setForm({...form,zip:e.target.value})} />
            <button className="btn" type="submit">Place order</button>
          </div>
          {error && <div className="toast" role="alert">{error}</div>}
        </form>
        <div className="summary">
          <h3>Order summary</h3>
          {items.length===0 ? <p>No items.</p> : (
            <ul>
              {items.map(i => (
                <li key={i.id}>{i.name} — {i.qty} × ${i.price.toFixed(2)}</li>
              ))}
            </ul>
          )}
          <div className="total" style={{marginTop:'.5rem'}}>
            <span>Total</span><span>${total.toFixed(2)}</span>
          </div>
        </div>
      </div>
    </div>
  )
}
