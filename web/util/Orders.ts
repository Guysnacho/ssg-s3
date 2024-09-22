import { ProductProps } from "@/pages";

export const handlePurchase = (user_id: string, product: ProductProps) => {
  console.debug(`Purchasing ${product.name} for $${product.price}`);
  fetch(`${process.env.NEXT_PUBLIC_APIGW}/sale`, {
    method: "POST",
    body: JSON.stringify({ quantity: 1, sku: product.sku, user_id }),
  })
    .then(async (res) => {
      const body = await res.json();
      console.debug(body);
    })
    .catch((err) => {
      console.error(err);
      alert("Failed to complete your purchase. Please try again later.");
    });
};
