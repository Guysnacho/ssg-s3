import { ProductProps } from "@/pages";

export const handlePurchase = (product: ProductProps) => {
  alert(`Purchasing ${product.name} for $${product.price}`);
};
