import { ProductProps } from "@/pages";
import {
  Box,
  Button,
  Center,
  Heading,
  Image,
  Stack,
  Text,
  useColorModeValue,
} from "@chakra-ui/react";
import { Dispatch, SetStateAction } from "react";

export default function Product({
  name,
  price,
  item_url,
  sku,
  setSelected,
}: {
  setSelected: Dispatch<SetStateAction<ProductProps | undefined>>;
} & ProductProps) {
  return (
    <Center py={12}>
      <Box
        role={"group"}
        p={6}
        maxW={"330px"}
        w={"full"}
        bg={useColorModeValue("white", "gray.800")}
        boxShadow={"2xl"}
        rounded={"lg"}
        pos={"relative"}
        zIndex={1}
      >
        <Box
          rounded={"lg"}
          mt={-12}
          pos={"relative"}
          height={"230px"}
          _after={{
            transition: "all .3s ease",
            content: '""',
            w: "full",
            h: "full",
            pos: "absolute",
            top: 5,
            left: 0,
            backgroundImage: item_url ? `url(${item_url})` : undefined,
            filter: "blur(15px)",
            zIndex: -1,
          }}
          _groupHover={{
            _after: {
              filter: "blur(20px)",
            },
          }}
        >
          <Image
            rounded={"lg"}
            height={230}
            width={282}
            objectFit={"cover"}
            src={item_url}
            alt="#"
          />
        </Box>
        <Stack pt={10} align={"center"}>
          <Text color={"gray.500"} fontSize={"sm"} textTransform={"uppercase"}>
            Artist
          </Text>
          <Heading
            textAlign="center"
            fontSize={"2xl"}
            fontFamily={"body"}
            fontWeight={500}
          >
            {name}
          </Heading>
          <Text fontWeight={800} fontSize={"xl"}>
            ${price}
          </Text>
          <Button
            colorScheme="green"
            variant="ghost"
            onClick={() => setSelected({ name, price, item_url, sku })}
          >
            Purchase
          </Button>
        </Stack>
      </Box>
    </Center>
  );
}
