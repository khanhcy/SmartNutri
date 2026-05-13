import { useState, useMemo, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { useFoods, FoodItem, FoodFormData } from "../hooks/useFoods";
import Papa from "papaparse";

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

function numberValue(value: unknown, fallback = 0): number {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string") {
    const parsed = Number(value.replace(/[^0-9.]/g, ""));
    if (Number.isFinite(parsed)) return parsed;
  }
  return fallback;
}

function parseCsvFood(row: Record<string, string>): FoodFormData {
  return {
    name: row.name ?? "",
    category: row.category ?? "",
    calorieKcal: numberValue(row.calorieKcal ?? row.calories),
    proteinG: numberValue(row.proteinG ?? row.protein),
    carbG: numberValue(row.carbG ?? row.carbs),
    fatG: numberValue(row.fatG ?? row.fat),
    defaultPortionG: numberValue(row.defaultPortionG ?? row.servingSize, 100),
    region: row.region || undefined,
    brand: row.brand || undefined,
    tags: row.tags
      ? row.tags.split(",").map((t) => t.trim()).filter(Boolean)
      : undefined,
    imageUrl: row.imageUrl || undefined,
    verified: row.verified === "true",
  };
}

export function FoodsPage() {
  const { foods, loading, deleteFood, importFoods } = useFoods();
  const [search, setSearch] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("");
  const [sortKey, setSortKey] = useState<keyof FoodItem>("name");
  const [sortDir, setSortDir] = useState<"asc" | "desc">("asc");
  const [deleting, setDeleting] = useState<string | null>(null);
  const [importing, setImporting] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);
  const navigate = useNavigate();

  const handleSort = (key: keyof FoodItem) => {
    if (sortKey === key) {
      setSortDir((d) => (d === "asc" ? "desc" : "asc"));
    } else {
      setSortKey(key);
      setSortDir("asc");
    }
  };

  const filtered = useMemo(() => {
    let list = foods;
    if (search) {
      const q = search.toLowerCase();
      list = list.filter((f) => f.name.toLowerCase().includes(q));
    }
    if (categoryFilter) {
      list = list.filter((f) => f.category === categoryFilter);
    }
    list = [...list].sort((a, b) => {
      const aVal = a[sortKey];
      const bVal = b[sortKey];
      if (aVal == null && bVal == null) return 0;
      if (aVal == null) return 1;
      if (bVal == null) return -1;
      if (typeof aVal === "number" && typeof bVal === "number") {
        return sortDir === "asc" ? aVal - bVal : bVal - aVal;
      }
      const sa = String(aVal);
      const sb = String(bVal);
      return sortDir === "asc" ? sa.localeCompare(sb) : sb.localeCompare(sa);
    });
    return list;
  }, [foods, search, categoryFilter, sortKey, sortDir]);

  const handleDelete = async (id: string) => {
    setDeleting(id);
    await deleteFood(id);
    setDeleting(null);
  };

  const handleCsvImport = async (
    e: React.ChangeEvent<HTMLInputElement>
  ) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setImporting(true);

    Papa.parse<Record<string, string>>(file, {
      header: true,
      skipEmptyLines: true,
      complete: async (results) => {
        const items = results.data.map(parseCsvFood);
        await importFoods(items);
        setImporting(false);
        if (fileRef.current) fileRef.current.value = "";
      },
      error: () => {
        setImporting(false);
      },
    });
  };

  if (loading) {
    return <p>Đang tải thực phẩm...</p>;
  }

  return (
    <div>
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          marginBottom: 24,
        }}
      >
        <h1 style={{ margin: 0, color: "#1b5e20" }}>Thực phẩm ({filtered.length})</h1>
        <div style={{ display: "flex", gap: 8 }}>
          <label
            style={{
              padding: "10px 16px",
              backgroundColor: "#f57c00",
              color: "#fff",
              borderRadius: 6,
              cursor: importing ? "not-allowed" : "pointer",
              fontSize: 13,
              fontWeight: 600,
              opacity: importing ? 0.7 : 1,
            }}
          >
            {importing ? "Đang import..." : "Import CSV"}
            <input
              ref={fileRef}
              type="file"
              accept=".csv"
              onChange={handleCsvImport}
              disabled={importing}
              hidden
            />
          </label>
          <button
            onClick={() => navigate("/foods/new")}
            style={{
              padding: "10px 16px",
              backgroundColor: "#2E7D32",
              color: "#fff",
              border: "none",
              borderRadius: 6,
              cursor: "pointer",
              fontSize: 13,
              fontWeight: 600,
            }}
          >
            + Thêm thực phẩm
          </button>
        </div>
      </div>

      <div
        style={{
          display: "flex",
          gap: 12,
          marginBottom: 16,
          backgroundColor: "#fff",
          padding: 12,
          borderRadius: 8,
          boxShadow: "0 1px 4px rgba(0,0,0,0.06)",
        }}
      >
        <input
          placeholder="Tìm kiếm..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          style={{
            flex: 1,
            padding: "8px 12px",
            border: "1px solid #ddd",
            borderRadius: 6,
            fontSize: 13,
          }}
        />
        <select
          value={categoryFilter}
          onChange={(e) => setCategoryFilter(e.target.value)}
          style={{
            width: 180,
            padding: "8px 12px",
            border: "1px solid #ddd",
            borderRadius: 6,
            fontSize: 13,
          }}
        >
          <option value="">Tất cả danh mục</option>
          {CATEGORIES.map((c) => (
            <option key={c} value={c}>
              {c}
            </option>
          ))}
        </select>
      </div>

      <div
        style={{
          backgroundColor: "#fff",
          borderRadius: 8,
          boxShadow: "0 1px 4px rgba(0,0,0,0.06)",
          overflow: "auto",
        }}
      >
        <table
          style={{
            width: "100%",
            borderCollapse: "collapse",
            fontSize: 13,
          }}
        >
          <thead>
            <tr style={{ backgroundColor: "#e8f5e9" }}>
              <Th onClick={() => handleSort("name")}>Tên</Th>
              <Th onClick={() => handleSort("category")}>Danh mục</Th>
              <Th onClick={() => handleSort("calorieKcal")}>Calo</Th>
              <Th onClick={() => handleSort("proteinG")}>Đạm</Th>
              <Th onClick={() => handleSort("carbG")}>Carb</Th>
              <Th onClick={() => handleSort("fatG")}>Béo</Th>
              <Th onClick={() => handleSort("brand")}>Thương hiệu</Th>
              <Th>Hành động</Th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((f) => (
              <tr
                key={f.id}
                style={{ borderBottom: "1px solid #eee" }}
              >
                <Td>
                  {f.name}
                  {f.verified && (
                    <span
                      style={{
                        color: "#2E7D32",
                        marginLeft: 4,
                        fontSize: 11,
                      }}
                    >
                      ✓
                    </span>
                  )}
                </Td>
                <Td>{f.category}</Td>
                <Td>{f.calorieKcal}</Td>
                <Td>{f.proteinG}g</Td>
                <Td>{f.carbG}g</Td>
                <Td>{f.fatG}g</Td>
                <Td>{f.brand ?? "-"}</Td>
                <Td>
                  <button
                    onClick={() => navigate(`/foods/${f.id}`)}
                    style={{
                      padding: "4px 10px",
                      backgroundColor: "#e3f2fd",
                      color: "#1565c0",
                      border: "none",
                      borderRadius: 4,
                      cursor: "pointer",
                      fontSize: 12,
                      marginRight: 4,
                    }}
                  >
                    Sửa
                  </button>
                  <button
                    onClick={() => handleDelete(f.id)}
                    disabled={deleting === f.id}
                    style={{
                      padding: "4px 10px",
                      backgroundColor: "#ffebee",
                      color: "#c62828",
                      border: "none",
                      borderRadius: 4,
                      cursor: "pointer",
                      fontSize: 12,
                      opacity: deleting === f.id ? 0.5 : 1,
                    }}
                  >
                    Xóa
                  </button>
                </Td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr>
                <Td colSpan={8}>Không tìm thấy thực phẩm nào.</Td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function Th({
  children,
  onClick,
}: {
  children: React.ReactNode;
  onClick?: () => void;
}) {
  return (
    <th
      onClick={onClick}
      style={{
        padding: "12px",
        textAlign: "left",
        fontWeight: 600,
        cursor: onClick ? "pointer" : "default",
        userSelect: "none",
      }}
    >
      {children}
    </th>
  );
}

function Td({
  children,
  colSpan,
}: {
  children: React.ReactNode;
  colSpan?: number;
}) {
  return (
    <td style={{ padding: "10px 12px" }} colSpan={colSpan}>
      {children}
    </td>
  );
}
