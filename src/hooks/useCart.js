import { useEffect, useMemo, useReducer, useState } from 'react'
const STORAGE_KEY = 'eztech-cart-v3'
const initialState = { items: [] }
function reducer(state, action){
  switch(action.type){
    case 'INIT': return action.payload
    case 'ADD_ITEM': {
      if(action.payload.kind==='subscription'){
        const hasSub = state.items.some(i=>i.kind==='subscription')
        if(hasSub) return { ...state, _warn: 'Only one subscription can be added at a time' }
      }
      const idx = state.items.findIndex(i=>i.id===action.payload.id)
      if(idx>=0){
        if(state.items[idx].kind==='accessory'){
          const copy=[...state.items]; copy[idx]={...copy[idx], qty: copy[idx].qty+1}
          return { ...state, items: copy, _warn: null }
        }
        return { ...state, _warn: 'Subscription already in cart' }
      }
      return { ...state, items: [...state.items, action.payload], _warn: null }
    }
    case 'REMOVE_ITEM': return { ...state, items: state.items.filter(i=>i.id!==action.payload) }
    case 'ADJUST_QTY': {
      const {id,delta} = action.payload
      const copy = state.items.map(i => i.id===id ? { ...i, qty: Math.max( i.kind==='subscription'?1:0, i.qty+delta ) } : i )
        .filter(i => i.qty>0 || i.kind==='subscription')
      return { ...state, items: copy }
    }
    case 'CLEAR_CART': return { items: [] }
    case 'CLEAR_WARN': return { ...state, _warn: null }
    default: return state
  }
}
export function useCart(){
  const [state, dispatch] = useReducer(reducer, initialState)
  const [ready, setReady] = useState(false)
  useEffect(()=>{
    try{ const raw=localStorage.getItem(STORAGE_KEY); if(raw){dispatch({type:'INIT',payload:JSON.parse(raw)})} }catch{}
    setReady(true)
  },[])
  useEffect(()=>{
    if(!ready) return
    const { _warn, ...clean } = state
    localStorage.setItem(STORAGE_KEY, JSON.stringify(clean))
  }, [state, ready])
  const total = useMemo(()=> state.items.reduce((s,i)=>s+i.price*i.qty,0), [state.items])
  const count = useMemo(()=> state.items.reduce((n,i)=>n+i.qty,0), [state.items])
  return {
    items: state.items, total, count, warning: state._warn, ready,
    addItem: (it)=>dispatch({type:'ADD_ITEM',payload:it}),
    removeItem: (id)=>dispatch({type:'REMOVE_ITEM',payload:id}),
    inc: (id)=>dispatch({type:'ADJUST_QTY',payload:{id,delta:1}}),
    dec: (id)=>dispatch({type:'ADJUST_QTY',payload:{id,delta:-1}}),
    clearCart: ()=>dispatch({type:'CLEAR_CART'}),
    clearWarn: ()=>dispatch({type:'CLEAR_WARN'}),
  }
}
