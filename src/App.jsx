import React, { useEffect, useState } from 'react'
import { Routes, Route } from 'react-router-dom'
import NavBar from './components/NavBar.jsx'
import CartDrawer from './components/CartDrawer.jsx'
import Home from './pages/Home.jsx'
import Subscriptions from './pages/Subscriptions.jsx'
import Accessories from './pages/Accessories.jsx'
import CartPage from './pages/CartPage.jsx'
import Checkout from './pages/Checkout.jsx'
import { useCart } from './hooks/useCart.js'

export default function App(){
  const { items, total, count, addItem, inc, dec, removeItem, clearCart, warning, clearWarn, ready } = useCart()
  const [open, setOpen] = useState(false)

  useEffect(()=>{
    if(!warning) return
    const t = setTimeout(()=>clearWarn(), 4000)
    return ()=>clearTimeout(t)
  }, [warning])

  if(!ready) return null

  return (
    <div>
      <NavBar onOpenCart={()=>setOpen(true)} count={count} />
      <div className="container" aria-live="polite" aria-atomic="true">
        {warning && <div className="toast">{warning}</div>}
      </div>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/subscriptions" element={<Subscriptions add={addItem} />} />
        <Route path="/accessories" element={<Accessories add={addItem} />} />
        <Route path="/cart" element={<CartPage items={items} total={total} inc={inc} dec={dec} remove={removeItem} />} />
        <Route path="/checkout" element={<Checkout items={items} total={total} clearCart={clearCart} />} />
      </Routes>
      <CartDrawer
        open={open}
        items={items}
        total={total}
        onClose={()=>setOpen(false)}
        inc={inc}
        dec={dec}
        remove={removeItem}
      />
      <div className="container footer">© EZTech Store — Week 3 Cart System</div>
    </div>
  )
}
