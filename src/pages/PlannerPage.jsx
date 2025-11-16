import React, { useState } from "react";
import { useApp } from "../context/AppContext";

export default function PlannerPage() {
  const {
    plannerItems,
    addPlannerItem,
    updatePlannerItem,
    togglePlannerComplete,
    deletePlannerItem,
  } = useApp();

  const [text, setText] = useState("");
  const [editingId, setEditingId] = useState(null);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!text.trim()) return;

    if (editingId) {
      updatePlannerItem(editingId, text);
      setEditingId(null);
    } else {
      addPlannerItem(text);
    }
    setText("");
  };

  const startEdit = (item) => {
    setEditingId(item.id);
    setText(item.text);
  };

  const cancelEdit = () => {
    setEditingId(null);
    setText("");
  };

  return (
    <div className="page">
      <div className="page-header">
        <h2 className="page-title">Stream Planner</h2>
        <p className="page-subtitle">
          Add, edit and complete items in your streaming to-do list.
        </p>
      </div>

      <form onSubmit={handleSubmit} className="form-row">
        <input
          type="text"
          placeholder="Add a movie or show to your planner"
          value={text}
          onChange={(e) => setText(e.target.value)}
        />
        <button type="submit" className="btn-primary-link">
          {editingId ? "Update entry" : "Add to planner"}
        </button>
        {editingId && (
          <button
            type="button"
            className="btn-secondary"
            onClick={cancelEdit}
          >
            Cancel
          </button>
        )}
      </form>

      <div className="planner-list">
        {plannerItems.length === 0 && (
          <p className="muted">No planner entries yet. Start by adding one.</p>
        )}
        {plannerItems.map((item) => (
          <div
            key={item.id}
            className={
              "planner-item" + (item.completed ? " planner-item-completed" : "")
            }
          >
            <div
              className="planner-item-main"
              onClick={() => togglePlannerComplete(item.id)}
            >
              <span className="planner-item-text">{item.text}</span>
              <span className="planner-item-meta">
                {new Date(item.createdAt).toLocaleString()}
              </span>
            </div>
            <div className="planner-item-actions">
              <button
                type="button"
                className="btn-secondary"
                onClick={() => startEdit(item)}
              >
                Edit
              </button>
              <button
                type="button"
                className="btn-secondary"
                onClick={() => deletePlannerItem(item.id)}
              >
                Delete
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
