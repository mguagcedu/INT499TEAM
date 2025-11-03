import React from 'react'
import {subscriptions} from '../Data'
export default function SubscriptionList({add}){
 return(<div><h2>Subscriptions</h2>{subscriptions.map(s=>(<div key={s.id}><h3>{s.name}</h3><p>${s.price.toFixed(2)}</p><button onClick={()=>add({id:s.id,name:s.name,price:s.price,qty:1,kind:'subscription'})}>Add</button></div>))}</div>)}
