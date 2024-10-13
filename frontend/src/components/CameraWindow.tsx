import {
  Friend,
  useCreateFriend,
  useGetFriends,
  useSearchFriendByImage,
} from "@/api/api";
import { cn, dataURItoBlob } from "@/lib/utils";
import { CameraIcon } from "@radix-ui/react-icons";
import { useRef, useState } from "react";
import Webcam from "react-webcam";
import FriendCard from "./FriendCard";
import { Button } from "./ui/button";

type ImagePreviewProps = {
  image?: string;
} & React.HTMLAttributes<HTMLDivElement>;

const ImagePreview: React.FC<ImagePreviewProps> = ({ image, className }) => {
  return (
    <div
      className={cn("bg-contain bg-no-repeat bg-center", className)}
      style={{ backgroundImage: image ? `url(${image})` : "" }}
    />
  );
};

const videoConstraints = {
  width: 1920,
  height: 1080,
  facingMode: "environment",
};

const CameraWindow = () => {
  const [image, setImage] = useState<string>();
  const [friend, setFriend] = useState<Friend | undefined>();
  const [friendNotFound, setFriendNotFound] = useState(false);
  const [toggleList, setToggleList] = useState(false);
  const { friends } = useGetFriends();
  const webcamRef = useRef({} as Webcam);
  const { mutateAsync, isError } = useSearchFriendByImage();
  const { mutateAsync: addFriend } = useCreateFriend();

  const capture = () => {
    const imageString = webcamRef.current.getScreenshot() as string;
    setImage(imageString);
    // convert image string to file
    const imgBlob = dataURItoBlob(imageString);
    mutateAsync(imgBlob).then((data) => {
      if (data.detail === "No matching friend found") {
        setFriendNotFound(true);
        return;
      }
      setFriend(data as Friend);
    });
  };

  const handleAddFriend = () => {
    const imageString = webcamRef.current.getScreenshot() as string;
    setImage(imageString);
    const imgBlob = dataURItoBlob(imageString);
    addFriend(imgBlob).then((data) => {
      setFriend(data);
      setFriendNotFound(false);
    });
  };

  return (
    <div className="relative w-full h-full">
      <Webcam
        audio={false}
        className="w-screen h-screen object-cover"
        ref={webcamRef}
        screenshotFormat="image/jpeg"
        videoConstraints={videoConstraints}
      />
      <div className="absolute left-0 top-1/4 pl-4">
        {isError ||
          (friendNotFound && (
            <div className="text-red-500">
              <p>Failed to find friend</p>
              <Button onClick={() => handleAddFriend()}>Add friend</Button>
            </div>
          ))}
        {friend && !isError && (
          <FriendCard
            friend={friend}
            setFriend={setFriend}
            onRemove={() => {
              setFriend(undefined);
              setImage("");
            }}
          />
        )}
      </div>
      <div className="absolute right-0 top-1/2 flex flex-col pr-10">
        {toggleList && (
          <div className="overflow-y-auto max-h-[44rem] space-y-4 mb-4">
            {friends && (
              <>
                <Button
                  onClick={() => setToggleList(!toggleList)}
                  className="mt-10 py-4"
                >
                  {toggleList ? "Hide" : "Show"} List
                </Button>
                {toggleList &&
                  friends.length > 0 &&
                  friends.map((friend: Friend) => (
                    <FriendCard
                      key={friend.id}
                      friend={friend}
                      setFriend={setFriend}
                    />
                  ))}
              </>
            )}
          </div>
        )}
        <Button onClick={capture}>
          <CameraIcon className="size-6" />
        </Button>
      </div>

      <div className="absolute right-0 top-3/4 flex flex-col space-y-4 pr-10"></div>
      <div className="absolute bottom-4 left-4 flex flex-wrap space-x-2 max-h-64 overflow-x-auto">
        {image && (
          <ImagePreview key={image} image={image} className="size-64" />
        )}
      </div>
    </div>
  );
};

export default CameraWindow;
