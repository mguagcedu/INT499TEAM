import React from 'react'
import {accessories} from '../Data'
export default function ProductList({add}){
 return(<div><h2>Accessories</h2>{accessories.map(p=>(<div key={p.id}><h3>{p.name}</h3><p>${p.price.toFixed(2)}</p><button onClick={()=>add({id:p.id,name:p.name,price:p.price,qty:1,kind:'accessory'})}>Add</button></div>))}</div>)}
