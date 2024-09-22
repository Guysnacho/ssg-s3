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
import { Dispatch, SetStateAction, useEffect, useState } from "react";

const inter = Inter({ subsets: ["latin"] });

export type ProductProps = {
  sku: string;
  name: string;
  price: number;
  item_url: string;
};

export default function Home() {
  const [user, _] = useState(localStorage.getItem("storefront-uid"));
  const [selected, setSelected] = useState<ProductProps | undefined>();
  const [productList, setProductList] = useState<ProductProps[]>([]);

  // Fetch Catalog
  useEffect(() => {
    fetchCatalog(setProductList);
  }, []);

  return (
    <div className={`container mx-auto ${inter.className}`}>
      {selected ? <p>Selected Item - {selected.name}</p> : undefined}
      <div className="flex flex-wrap w-4/5 mx-auto justify-evenly gap-5">
        {productList.map((item) => (
          <Product
            key={item.name}
            setSelected={setSelected}
            sku={item.sku}
            name={item.name}
            price={item.price}
            item_url={item.item_url}
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
                handlePurchase(user ?? "", selected!);
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

const fetchCatalog = async (
  setProductList: Dispatch<SetStateAction<ProductProps[]>>
) => {
  fetch(`${process.env.NEXT_PUBLIC_APIGW}/catalog`)
    .then(async (res) => {
      const body = await res.json();
      setProductList(body);
    })
    .catch((err) => {
      console.error(err);
      alert("Failed to fetch catalog");
    });
};
