import { ProductProps } from "@/pages";

export const handlePurchase = (user_id: string, product: ProductProps) => {
  if (!user_id) {
    alert("Oops, you're not logged in.");
    return;
  }
  console.debug(`Purchasing ${product.name} for $${product.price}`);
  fetch(`${process.env.NEXT_PUBLIC_APIGW}/sale`, {
    method: "POST",
    body: `{ "quantity": 1, "sku": "${product.sku}", "user_id": "${user_id}" }`,
  })
    .then(async (res) => {
      if (!res.ok) {
        throw new Error(
          "Failed to complete your purchase. Please try again later."
        );
      } else alert("Thank you for your purchase!");
    })
    .catch((err) => {
      console.error(err);
      alert("Failed to complete your purchase. Please try again later.");
    });
};
