import { AUTH_KEY, handleLogIn, handleSignUp } from "@/util/Auth";
import { CloseIcon, HamburgerIcon } from "@chakra-ui/icons";
import {
  Avatar,
  Box,
  Button,
  Flex,
  FormControl,
  FormLabel,
  Heading,
  HStack,
  IconButton,
  Image,
  Input,
  Menu,
  MenuButton,
  MenuItem,
  MenuList,
  Spinner,
  Stack,
  useColorModeValue,
  useDisclosure,
} from "@chakra-ui/react";
import { Dispatch, SetStateAction, useEffect, useState } from "react";

interface Props {
  children: React.ReactNode;
}

const Links = [
  { label: "Home", url: "/" },
  { label: "GitHub", url: "https://github.com/guysnacho" },
];
const AuthedLinks = [
  { label: "Home", url: "/" },
  { label: "GitHub", url: "https://github.com/guysnacho" },
  { label: "Logout", url: "#" },
];

const NavLink = ({
  label,
  url,
  setIsAuthed,
}: {
  url: string;
  label: string;
  setIsAuthed?: Dispatch<SetStateAction<boolean>>;
}) => {
  return (
    <Box
      as="a"
      px={2}
      py={1}
      rounded={"md"}
      onClick={
        label === "Logout"
          ? () => {
              localStorage.removeItem(AUTH_KEY);
              setIsAuthed!(false);
            }
          : undefined
      }
      _hover={{
        textDecoration: "none",
        bg: useColorModeValue("gray.200", "gray.700"),
      }}
      target={url.includes("http") ? "_blank" : "_self"}
      href={url}
    >
      {label}
    </Box>
  );
};

export default function Layout({ children }: Props) {
  const { isOpen, onOpen, onClose } = useDisclosure();
  const [isAuthed, setIsAuthed] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [fname, setFname] = useState("");
  const [lname, setLname] = useState("");
  const [method, setMethod] = useState<"SIGNUP" | "LOGIN" | undefined>();

  // Check user auth
  useEffect(() => {
    if (localStorage.getItem(AUTH_KEY) != null) {
      setIsAuthed(true);
    } else setIsAuthed(false);
  }, []);

  const handleAuth = async () => {
    if (method === "LOGIN") {
      await handleLogIn(email, password)
        .then((res) => {
          console.log(res);
          if (res?.body) {
            localStorage.setItem(AUTH_KEY, res.body.id);
            setIsAuthed(true);
          } else {
            alert(res.statusDescription);
          }
        })
        .finally(() => setIsLoading(false));
    } else if (method === "SIGNUP") {
      await handleSignUp(email, password, fname, lname)
        .then((res) => {
          console.log(res);
          if (res?.body) {
            localStorage.setItem(AUTH_KEY, res.body.id);
            setIsAuthed(true);
          } else {
            alert(res.statusDescription);
          }
        })
        .finally(() => setIsLoading(false));
    }
  };

  return (
    <>
      <Box bg={useColorModeValue("gray.100", "gray.900")} px={4}>
        <Flex h={16} alignItems={"center"} justifyContent={"space-between"}>
          <IconButton
            size={"md"}
            icon={isOpen ? <CloseIcon /> : <HamburgerIcon />}
            aria-label={"Open Menu"}
            display={{ md: "none" }}
            onClick={isOpen ? onClose : onOpen}
          />
          <HStack spacing={8} alignItems={"center"}>
            <Box>Definitely a store</Box>
            <HStack
              as={"nav"}
              spacing={4}
              display={{ base: "none", md: "flex" }}
            >
              {isAuthed
                ? AuthedLinks.map((link) => (
                    <NavLink
                      key={link.url}
                      label={link.label}
                      url={link.url}
                      setIsAuthed={setIsAuthed}
                    />
                  ))
                : Links.map((link) => (
                    <NavLink key={link.url} label={link.label} url={link.url} />
                  ))}
            </HStack>
          </HStack>
          <Flex alignItems={"center"}>
            {isAuthed ? (
              <Menu>
                <MenuButton
                  as={Button}
                  rounded={"full"}
                  variant={"link"}
                  cursor={"pointer"}
                  minW={0}
                >
                  <Avatar
                    size={"sm"}
                    src={
                      "https://images.unsplash.com/photo-1493666438817-866a91353ca9?ixlib=rb-0.3.5&q=80&fm=jpg&crop=faces&fit=crop&h=200&w=200&s=b616b2c5b373a80ffc9636ba24f7a4a9"
                    }
                  />
                </MenuButton>
                <MenuList>
                  {AuthedLinks.map((link) => (
                    <MenuItem key={link.url}>
                      <NavLink
                        label={link.label}
                        url={link.url}
                        setIsAuthed={setIsAuthed}
                      />
                    </MenuItem>
                  ))}
                </MenuList>
              </Menu>
            ) : (
              <>
                <Button
                  rounded={"full"}
                  cursor={"pointer"}
                  minW={0}
                  onClick={() => {
                    // setIsLoading(true);
                    // handleSignUp().finally(() => setIsLoading(false));
                    setMethod(method === "SIGNUP" ? undefined : "SIGNUP");
                  }}
                >
                  Sign Up
                </Button>
                <Button
                  rounded={"full"}
                  cursor={"pointer"}
                  minW={0}
                  onClick={() => {
                    // setIsLoading(true);
                    // handleLogIn().finally(() => setIsLoading(false));
                    setMethod(method === "LOGIN" ? undefined : "LOGIN");
                  }}
                >
                  Log In
                </Button>
              </>
            )}
          </Flex>
        </Flex>

        {isOpen ? (
          <Box pb={4} display={{ md: "none" }}>
            <Stack as={"nav"} spacing={4}>
              {isAuthed
                ? AuthedLinks.map((link) => (
                    <NavLink
                      key={link.url}
                      label={link.label}
                      url={link.url}
                      setIsAuthed={setIsAuthed}
                    />
                  ))
                : Links.map((link) => (
                    <NavLink key={link.url} label={link.label} url={link.url} />
                  ))}
            </Stack>
          </Box>
        ) : null}
      </Box>

      {method ? (
        <Stack minH={"25vh"} direction={{ base: "column", md: "row" }}>
          <Flex p={8} flex={1} align={"center"} justify={"center"}>
            <Stack spacing={4} w={"full"} maxW={"md"}>
              <Heading fontSize={"2xl"}>
                {method == "LOGIN"
                  ? "Log in to your account"
                  : "Sign up for an account"}
              </Heading>
              {method === "LOGIN" ? (
                <>
                  <FormControl id="email">
                    <FormLabel>Email address</FormLabel>
                    <Input
                      value={email}
                      onChange={(e) => setEmail((e.target as any).value)}
                      type="email"
                    />
                  </FormControl>
                  <FormControl id="password">
                    <FormLabel>Password</FormLabel>
                    <Input
                      value={password}
                      onChange={(e) => setPassword((e.target as any).value)}
                      type="password"
                    />
                  </FormControl>
                </>
              ) : (
                <>
                  <FormControl id="email">
                    <FormLabel>Email address</FormLabel>
                    <Input
                      value={email}
                      onChange={(e) => setEmail((e.target as any).value)}
                      type="email"
                    />
                  </FormControl>
                  <FormControl id="password">
                    <FormLabel>Password</FormLabel>
                    <Input
                      value={password}
                      onChange={(e) => setPassword((e.target as any).value)}
                      type="password"
                    />
                  </FormControl>
                  <FormControl id="fname">
                    <FormLabel>First Name</FormLabel>
                    <Input
                      value={fname}
                      onChange={(e) => setFname((e.target as any).value)}
                      type="text"
                    />
                  </FormControl>
                  <FormControl id="lname">
                    <FormLabel>Last Name</FormLabel>
                    <Input
                      value={lname}
                      onChange={(e) => setLname((e.target as any).value)}
                      type="text"
                    />
                  </FormControl>
                </>
              )}
              <Stack spacing={6}>
                <Button
                  colorScheme={"blue"}
                  rightIcon={isLoading ? <Spinner /> : undefined}
                  variant={"solid"}
                  onClick={() =>
                    handleAuth().finally(() => {
                      if (isAuthed) setMethod(undefined);
                      setIsLoading(false);
                    })
                  }
                >
                  {method === "LOGIN" ? "Log in" : "Sign up"}
                </Button>
              </Stack>
            </Stack>
          </Flex>
          <Flex flex={1}>
            <Image
              alt={"Login Image"}
              objectFit={"cover"}
              src={
                "https://images.unsplash.com/photo-1486312338219-ce68d2c6f44d?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1352&q=80"
              }
            />
          </Flex>
        </Stack>
      ) : undefined}

      <div>{children}</div>
    </>
  );
}
