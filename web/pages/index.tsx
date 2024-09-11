import Product from "@/components/Product";
import { Inter } from "next/font/google";

const inter = Inter({ subsets: ["latin"] });

export type ProductProps = {
  name: string;
  price: number;
  thumbnail: string;
};
const productList: ProductProps[] = [
  {
    name: "Bando Stone and The New World Vinyl",
    price: 45.15,
    thumbnail:
      "https://t2.genius.com/unsafe/728x0/https%3A%2F%2Fimages.genius.com%2Ff19320aae82a75396d97def01ae89ff3.1000x1000x1.png",
  },
];

export default function Home() {
  return (
    <div className="container mx-auto">
      <div className="w-4/5 mx-auto">
        {productList.map((item) => (
          <Product
            key={item.name}
            name={item.name}
            price={item.price}
            thumbnail={item.thumbnail}
          />
        ))}
      </div>
    </div>
  );
}
