import Product from "@/components/Product";
import { handlePurchase } from "@/util/Orders";
import {
  Button,
  Modal,
  ModalBody,
  ModalCloseButton,
  ModalContent,
  ModalFooter,
  ModalHeader,
  ModalOverlay,
} from "@chakra-ui/react";
import { Inter } from "next/font/google";
import { useState } from "react";

const inter = Inter({ subsets: ["latin"] });

export type ProductProps = {
  name: string;
  price: number;
  thumbnail: string;
};

const productList: ProductProps[] = [
  {
    name: "Bando Stone and The New World",
    price: 45.15,
    thumbnail:
      "https://t2.genius.com/unsafe/728x0/https%3A%2F%2Fimages.genius.com%2Ff19320aae82a75396d97def01ae89ff3.1000x1000x1.png",
  },
  {
    name: "alligator bites never heal - Doechii",
    price: 30,
    thumbnail:
      "https://shop.capitolmusic.com/cdn/shop/files/DoechiiABNHLPInsert.png?v=1724951711&width=800",
  },
  {
    name: "Nova - James Fauntleroy, Terrace Martin",
    price: 30.99,
    thumbnail:
      "https://images.squarespace-cdn.com/content/v1/5699291fa976afc919dbca7d/a701db3b-83c1-457b-a892-0c46b0e6749c/Nova+Artwork.jpg?format=500w",
  },
];

export default function Home() {
  const [selected, setSelected] = useState<ProductProps | undefined>();
  return (
    <div className={`container mx-auto ${inter.className}`}>
      {selected ? <p>Selected Item - {selected.name}</p> : undefined}
      <div className="flex flex-wrap w-4/5 mx-auto justify-evenly gap-5">
        {productList.map((item) => (
          <Product
            key={item.name}
            setSelected={setSelected}
            name={item.name}
            price={item.price}
            thumbnail={item.thumbnail}
          />
        ))}
      </div>
      <Modal
        onClose={() => setSelected(undefined)}
        isOpen={selected !== undefined}
        isCentered
      >
        <ModalOverlay />
        <ModalContent>
          <ModalHeader>Oooohhh so you like our goods do you?</ModalHeader>
          <ModalCloseButton />
          <ModalBody>
            <div>
              <h4>{selected?.name}</h4>
              <p>{selected?.price}</p>
            </div>
          </ModalBody>
          <ModalFooter sx={{ gap: 5 }}>
            <Button onClick={() => setSelected(undefined)}>Cancel</Button>
            <Button
              colorScheme="green"
              onClick={() => {
                handlePurchase(selected!);
                setSelected(undefined);
              }}
            >
              Checkout
            </Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </div>
  );
}
