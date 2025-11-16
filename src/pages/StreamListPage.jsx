import React, { useState } from "react";
import { useApp } from "../context/AppContext";

export default function StreamListPage() {
  const {
    plannerItems,
    addPlannerItem,
    togglePlannerComplete,
    updatePlannerItem,
    deletePlannerItem,
  } = useApp();
  const [text, setText] = useState("");
  const [editingId, setEditingId] = useState(null);
  const [editingText, setEditingText] = useState("");

  function handleSubmit(e) {
    e.preventDefault();
    if (!text.trim()) return;
    addPlannerItem(text);
    setText("");
  }

  function startEdit(item) {
    setEditingId(item.id);
    setEditingText(item.text);
  }

  function saveEdit(item) {
    if (editingText.trim()) {
      updatePlannerItem(item.id, editingText);
    }
    setEditingId(null);
    setEditingText("");
  }

  return (
    <div className="page-shell">
      <div className="page-card">
        <h1 className="page-title">Stream planner</h1>
        <p className="page-subtitle">
          Add, edit, and complete your upcoming movies or shows. Entries are
          stored in your browser so they are still there when you come back.
        </p>

        <form className="planner-form" onSubmit={handleSubmit}>
          <input
            type="text"
            placeholder="What do you want to watch next?"
            value={text}
            onChange={(e) => setText(e.target.value)}
          />
          <button type="submit">Add to plan</button>
        </form>

        <ul className="planner-list">
          {plannerItems.length === 0 && (
            <li className="planner-empty">No entries yet. Add your first plan.</li>
          )}

          {plannerItems.map((item) => (
            <li key={item.id} className="planner-item">
              <div className="planner-left">
                <input
                  type="checkbox"
                  checked={item.completed}
                  onChange={() => togglePlannerComplete(item.id)}
                />
                {editingId === item.id ? (
                  <input
                    className="planner-edit-input"
                    value={editingText}
                    onChange={(e) => setEditingText(e.target.value)}
                    onKeyDown={(e) => {
                      if (e.key === "Enter") {
                        e.preventDefault();
                        saveEdit(item);
                      }
                    }}
                  />
                ) : (
                  <span
                    className={
                      item.completed ? "planner-text planner-text-done" : "planner-text"
                    }
                  >
                    {item.text}
                  </span>
                )}
              </div>
              <div className="planner-actions">
                {editingId === item.id ? (
                  <button type="button" onClick={() => saveEdit(item)}>
                    Save
                  </button>
                ) : (
                  <button type="button" onClick={() => startEdit(item)}>
                    Edit
                  </button>
                )}
                <button
                  type="button"
                  className="danger"
                  onClick={() => deletePlannerItem(item.id)}
                >
                  Delete
                </button>
              </div>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
