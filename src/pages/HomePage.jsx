import React, { useState } from "react";
import { useApp } from "../context/AppContext";

export default function HomePage() {
  const {
    plannerItems,
    addPlannerItem,
    togglePlannerItem,
    updatePlannerItem,
    deletePlannerItem
  } = useApp();

  const [text, setText] = useState("");
  const [editingId, setEditingId] = useState(null);
  const [editText, setEditText] = useState("");

  function handleSubmit(e) {
    e.preventDefault();
    addPlannerItem(text);
    setText("");
  }

  function startEdit(item) {
    setEditingId(item.id);
    setEditText(item.text);
  }

  function saveEdit(e) {
    e.preventDefault();
    if (!editingId) return;
    updatePlannerItem(editingId, editText);
    setEditingId(null);
    setEditText("");
  }

  return (
    <section>
      <h2 style={{ fontSize: 22, marginBottom: 8 }}>StreamList planner</h2>
      <p style={{ fontSize: 13, color: "var(--text-muted)", marginBottom: 14 }}>
        Add titles you want to watch and check them off as you go. Your list is
        saved to this device using local storage.
      </p>

      <form
        onSubmit={handleSubmit}
        style={{
          display: "flex",
          gap: 8,
          marginBottom: 14
        }}
      >
        <input
          type="text"
          placeholder="Add a movie or show..."
          value={text}
          onChange={(e) => setText(e.target.value)}
          style={{
            flex: 1,
            padding: "8px 10px",
            borderRadius: 8,
            border: "1px solid var(--border-subtle)",
            backgroundColor: "var(--bg-surface)",
            color: "var(--text-main)",
            fontSize: 13
          }}
        />
        <button
          type="submit"
          style={{
            padding: "8px 14px",
            borderRadius: 999,
            border: "none",
            backgroundColor: "var(--accent-primary)",
            color: "#020617",
            fontSize: 13,
            fontWeight: 600,
            cursor: "pointer"
          }}
        >
          Add
        </button>
      </form>

      {plannerItems.length === 0 ? (
        <p style={{ fontSize: 13, color: "var(--text-subtle)" }}>
          No items yet. Start by adding something you plan to watch.
        </p>
      ) : (
        <ul
          style={{
            listStyle: "none",
            padding: 0,
            margin: 0,
            display: "flex",
            flexDirection: "column",
            gap: 6
          }}
        >
          {plannerItems.map((item) => (
            <li
              key={item.id}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 8,
                padding: "6px 8px",
                borderRadius: 8,
                border: "1px solid var(--border-subtle)",
                backgroundColor: "var(--bg-surface)"
              }}
            >
              <input
                type="checkbox"
                checked={item.completed}
                onChange={() => togglePlannerItem(item.id)}
              />
              {editingId === item.id ? (
                <form
                  onSubmit={saveEdit}
                  style={{ display: "flex", flex: 1, gap: 6 }}
                >
                  <input
                    value={editText}
                    onChange={(e) => setEditText(e.target.value)}
                    style={{
                      flex: 1,
                      padding: "4px 6px",
                      borderRadius: 6,
                      border: "1px solid var(--border-subtle)",
                      backgroundColor: "var(--bg-surface)",
                      color: "var(--text-main)",
                      fontSize: 13
                    }}
                  />
                  <button
                    type="submit"
                    style={{
                      padding: "4px 8px",
                      borderRadius: 999,
                      border: "none",
                      backgroundColor: "var(--accent-success)",
                      color: "#020617",
                      fontSize: 11,
                      cursor: "pointer"
                    }}
                  >
                    Save
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setEditingId(null);
                      setEditText("");
                    }}
                    style={{
                      padding: "4px 8px",
                      borderRadius: 999,
                      border: "1px solid var(--border-subtle)",
                      backgroundColor: "transparent",
                      color: "var(--text-main)",
                      fontSize: 11,
                      cursor: "pointer"
                    }}
                  >
                    Cancel
                  </button>
                </form>
              ) : (
                <>
                  <span
                    style={{
                      flex: 1,
                      fontSize: 13,
                      textDecoration: item.completed
                        ? "line-through"
                        : "none",
                      color: item.completed
                        ? "var(--text-subtle)"
                        : "var(--text-main)"
                    }}
                  >
                    {item.text}
                  </span>
                  <button
                    type="button"
                    onClick={() => startEdit(item)}
                    style={{
                      padding: "3px 7px",
                      borderRadius: 999,
                      border: "1px solid var(--border-subtle)",
                      backgroundColor: "transparent",
                      color: "var(--text-main)",
                      fontSize: 11,
                      cursor: "pointer"
                    }}
                  >
                    Edit
                  </button>
                  <button
                    type="button"
                    onClick={() => deletePlannerItem(item.id)}
                    style={{
                      padding: "3px 7px",
                      borderRadius: 999,
                      border: "none",
                      backgroundColor: "var(--accent-danger)",
                      color: "#f9fafb",
                      fontSize: 11,
                      cursor: "pointer"
                    }}
                  >
                    Delete
                  </button>
                </>
              )}
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
