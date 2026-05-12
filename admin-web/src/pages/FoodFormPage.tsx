import { useState, useEffect, FormEvent } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { useFoods, FoodFormData } from "../hooks/useFoods";

const CATEGORIES = [
  "Món chính",
  "Món phụ",
  "Đồ uống",
  "Ăn vặt",
  "Fast Food",
  "Món Bắc",
  "Món Trung",
  "Món Nam",
];

const REGIONS = ["", "miền Bắc", "miền Trung", "miền Nam"];

const BRANDS = [
  "",
  "Highlands Coffee",
  "Phúc Long",
  "The Coffee House",
  "KFC",
  "McDonald's",
  "Lotteria",
  "Gong Cha",
  "Trung Nguyên Legend",
  "Starbucks",
  "Jollibee",
  "Bánh Mì Phượng",
  "Phở Thìn",
  "Bún Chả Hương Liên",
];

const TAGS = [
  "chay",
  "giàu đạm",
  "ăn kiêng",
  "low-carb",
  "truyền thống",
  "đường phố",
  "nhà hàng",
  "healthy",
];

const EMPTY_FORM: FoodFormData = {
  name: "",
  category: "Món chính",
  calories: 0,
  protein: 0,
  carbs: 0,
  fat: 0,
  fiber: 0,
  servingSize: "100g",
  region: undefined,
  brand: undefined,
  tags: undefined,
  imageUrl: undefined,
  verified: false,
};

export function FoodFormPage() {
  const { id } = useParams<{ id: string }>();
  const { foods, loading, addFood, updateFood } = useFoods();
  const [form, setForm] = useState<FoodFormData>(EMPTY_FORM);
  const [saving, setSaving] = useState(false);
  const navigate = useNavigate();
  const isEdit = id && id !== "new";

  useEffect(() => {
    if (!loading && isEdit) {
      const existing = foods.find((f) => f.id === id);
      if (existing) {
        const { id: _, ...rest } = existing;
        setForm(rest);
      }
    }
  }, [loading, id]);

  const set = (field: keyof FoodFormData, value: any) => {
    setForm((prev) => ({ ...prev, [field]: value }));
  };

  const toggleTag = (tag: string) => {
    const current = form.tags ?? [];
    set(
      "tags",
      current.includes(tag)
        ? current.filter((t) => t !== tag)
        : [...current, tag]
    );
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setSaving(true);
    if (isEdit) {
      await updateFood(id!, form);
    } else {
      await addFood(form);
    }
    setSaving(false);
    navigate("/foods");
  };

  if (loading) {
    return <p>Đang tải...</p>;
  }

  return (
    <div>
      <h1 style={{ margin: "0 0 24px", color: "#1b5e20" }}>
        {isEdit ? "Sửa thực phẩm" : "Thêm thực phẩm"}
      </h1>

      <form
        onSubmit={handleSubmit}
        style={{
          backgroundColor: "#fff",
          borderRadius: 10,
          padding: 24,
          boxShadow: "0 1px 6px rgba(0,0,0,0.08)",
          maxWidth: 700,
        }}
      >
        <Field label="Tên món" required>
          <input
            value={form.name}
            onChange={(e) => set("name", e.target.value)}
            required
            style={inputStyle}
          />
        </Field>

        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16 }}>
          <Field label="Danh mục" required>
            <select
              value={form.category}
              onChange={(e) => set("category", e.target.value)}
              style={inputStyle}
            >
              {CATEGORIES.map((c) => (
                <option key={c} value={c}>
                  {c}
                </option>
              ))}
            </select>
          </Field>

          <Field label="Khẩu phần">
            <input
              value={form.servingSize}
              onChange={(e) => set("servingSize", e.target.value)}
              style={inputStyle}
            />
          </Field>
        </div>

        <div
          style={{
            display: "grid",
            gridTemplateColumns: "1fr 1fr 1fr 1fr",
            gap: 16,
          }}
        >
          <Field label="Calo (kcal)" required>
            <input
              type="number"
              value={form.calories}
              onChange={(e) => set("calories", Number(e.target.value))}
              required
              style={inputStyle}
            />
          </Field>
          <Field label="Đạm (g)">
            <input
              type="number"
              value={form.protein}
              onChange={(e) => set("protein", Number(e.target.value))}
              style={inputStyle}
            />
          </Field>
          <Field label="Carb (g)">
            <input
              type="number"
              value={form.carbs}
              onChange={(e) => set("carbs", Number(e.target.value))}
              style={inputStyle}
            />
          </Field>
          <Field label="Béo (g)">
            <input
              type="number"
              value={form.fat}
              onChange={(e) => set("fat", Number(e.target.value))}
              style={inputStyle}
            />
          </Field>
        </div>

        <Field label="Chất xơ (g)">
          <input
            type="number"
            value={form.fiber}
            onChange={(e) => set("fiber", Number(e.target.value))}
            style={{ ...inputStyle, width: 150 }}
          />
        </Field>

        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16 }}>
          <Field label="Vùng miền">
            <select
              value={form.region ?? ""}
              onChange={(e) =>
                set("region", e.target.value || undefined)
              }
              style={inputStyle}
            >
              {REGIONS.map((r) => (
                <option key={r} value={r}>
                  {r || "(không)"}
                </option>
              ))}
            </select>
          </Field>

          <Field label="Thương hiệu">
            <select
              value={form.brand ?? ""}
              onChange={(e) =>
                set("brand", e.target.value || undefined)
              }
              style={inputStyle}
            >
              {BRANDS.map((b) => (
                <option key={b} value={b}>
                  {b || "(không)"}
                </option>
              ))}
            </select>
          </Field>
        </div>

        <Field label="Tags">
          <div style={{ display: "flex", flexWrap: "wrap", gap: 6 }}>
            {TAGS.map((tag) => {
              const active = (form.tags ?? []).includes(tag);
              return (
                <button
                  key={tag}
                  type="button"
                  onClick={() => toggleTag(tag)}
                  style={{
                    padding: "6px 12px",
                    borderRadius: 20,
                    border: active
                      ? "2px solid #2E7D32"
                      : "1px solid #ccc",
                    backgroundColor: active ? "#e8f5e9" : "#fff",
                    color: active ? "#2E7D32" : "#666",
                    cursor: "pointer",
                    fontSize: 12,
                    fontWeight: active ? 600 : 400,
                  }}
                >
                  {tag}
                </button>
              );
            })}
          </div>
        </Field>

        <Field label="URL ảnh">
          <input
            value={form.imageUrl ?? ""}
            onChange={(e) =>
              set("imageUrl", e.target.value || undefined)
            }
            style={inputStyle}
            placeholder="https://..."
          />
        </Field>

        <label style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 20 }}>
          <input
            type="checkbox"
            checked={form.verified}
            onChange={(e) => set("verified", e.target.checked)}
          />
          <span style={{ fontSize: 14 }}>Đã xác minh (admin verified)</span>
        </label>

        <div style={{ display: "flex", gap: 12 }}>
          <button
            type="submit"
            disabled={saving}
            style={{
              padding: "12px 24px",
              backgroundColor: "#2E7D32",
              color: "#fff",
              border: "none",
              borderRadius: 6,
              fontSize: 14,
              fontWeight: 600,
              cursor: saving ? "not-allowed" : "pointer",
              opacity: saving ? 0.7 : 1,
            }}
          >
            {saving ? "Đang lưu..." : isEdit ? "Cập nhật" : "Thêm mới"}
          </button>
          <button
            type="button"
            onClick={() => navigate("/foods")}
            style={{
              padding: "12px 24px",
              backgroundColor: "#fff",
              color: "#666",
              border: "1px solid #ccc",
              borderRadius: 6,
              fontSize: 14,
              cursor: "pointer",
            }}
          >
            Hủy
          </button>
        </div>
      </form>
    </div>
  );
}

function Field({
  label,
  required,
  children,
}: {
  label: string;
  required?: boolean;
  children: React.ReactNode;
}) {
  return (
    <label style={{ display: "block", marginBottom: 16 }}>
      <span style={{ display: "block", fontSize: 13, fontWeight: 600, marginBottom: 4 }}>
        {label}
        {required && <span style={{ color: "red" }}> *</span>}
      </span>
      {children}
    </label>
  );
}

const inputStyle: React.CSSProperties = {
  width: "100%",
  padding: "8px 12px",
  border: "1px solid #ddd",
  borderRadius: 6,
  fontSize: 13,
  boxSizing: "border-box",
};
